#!/usr/bin/env python
# Copyright 2016 Julien Pivotto <roidelapluie@inuits.eu>
# Released under the GNU General Public licence v3 or later

import os
import subprocess
from cicoclient.wrapper import CicoWrapper
from robot.api.deco import keyword
from tempfile import NamedTemporaryFile
import glob

def single_node(func):
    def check_single_node(suite, *args, **kwargs):
        assert len(suite.nodes) == 1, 'We expected only 1 node. Got: %s.' % len(suite.nodes)
        return func(suite, *args, **kwargs)
    return check_single_node

class DuffyLibrary(object):

    def __init__(self):
        # The connection to Duffy
        self.api = None
        # List of the populated Duffy nodes
        self.nodes = []
        self.ssid = []
        self.exec_nodes = []
        self.exit_codes = []

    def _setup_cico_connection(self):
        '''
        Populates self.api with the environment variables that we have. self.api will then
        be used to communicate with Duffy: requesting nodes, releasing nodes, ...
        '''
        if self.api is not None:
            return
        self.api = CicoWrapper(
            endpoint=os.environ['CICO_ENDPOINT'],
            api_key=os.environ['CICO_API_KEY']
        )

    def populate_a_duffy_node(self, **kwargs):
        self._setup_cico_connection()
        self.populate_duffy_nodes(1, **kwargs)

    @keyword('Populate ${count:\d} Duffy nodes')
    def populate_duffy_nodes(self, count=None, **kwargs):
        self._setup_cico_connection()
        assert len(self.nodes) == 0, 'Nodes have already been populated'
        nodes, self.ssid = self.api.node_get(count=count, retry_count=10,
                                                  retry_interval=60, **kwargs)
        self.nodes = nodes.values()

    def release_the_duffy_nodes(self):
        if self.ssid:
            self.api.node_done(ssid=self.ssid)

    @single_node
    def on_the_duffy_node(self):
        self.exec_nodes = self.nodes

    def get_glob_file(self, filename):
        files = glob.glob(filename)
        assert len(files) == 1, "Expected 1 file, found %s: %s" % (len(files), files)
        return files[0]

    def on_the_first_duffy_node(self):
        self.exec_nodes = [self.nodes[0]]

    def on_the_duffy_nodes(self):
        self.exec_nodes = self.nodes

    def i_try_to_run_locally(self, *args):
        self.exit_codes = [subprocess.call(*args)]

    def i_run_locally(self, *args):
        subprocess.check_call(args)

    def i_run(self, *args):
        self._exec_ssh_command(*args)

    def i_fetch_the_srpm(self):
        self._exec_sftp_get_command('SRPMS/*.src.rpm', os.environ['WORKSPACE'])

    def i_rsync_the_workspace(self):
        for node in self.exec_nodes:
            rsync_command = ['rsync']
            rsync_command.append('-e')
            rsync_command.append('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root')
            rsync_command.append('-rlpt')
            rsync_command.append(os.environ['WORKSPACE'] + '/')
            rsync_command.append(node['ip_address'] + ':ws')
            subprocess.check_call(rsync_command)

    def it_returns(self, value):
        for code in self.exit_codes:
            assert code == int(value), 'Should have returned %s, returned %s.' % (code, value)

    def i_add_a_cbs_yum_repo(self, reponame):
        with NamedTemporaryFile() as f:
            f.write("[%s]\n" % reponame)
            f.write("baseurl=http://cbs.centos.org/repos/%s/\n" % reponame)
            #FIXME
            f.write("gpgcheck=0\n" % reponame)
            f.flush()
            self._exec_sftp_send_command(f.name,'/etc/yum.repos.d/%s.repo' % reponame)

    def _exec_sftp_send_command(self, *args):
        for node in self.exec_nodes:
            scp_command = ['scp']
            scp_command.extend(['-o', 'UserKnownHostsFile=/dev/null'])
            scp_command.extend(['-o', 'StrictHostKeyChecking=no'])
            scp_command.append(args[0])
            scp_command.append('%s@%s:%s' % ('root', node['ip_address'], args[1]))
            subprocess.check_call(scp_command)

    def _exec_sftp_get_command(self, *args):
        for node in self.exec_nodes:
            scp_command = ['scp']
            scp_command.extend(['-o', 'UserKnownHostsFile=/dev/null'])
            scp_command.extend(['-o', 'StrictHostKeyChecking=no'])
            scp_command.append('%s@%s:%s' % ('root', node['ip_address'], args[0]))
            scp_command.append(args[1])
            subprocess.check_call(scp_command)

    def _exec_ssh_command(self, *args):
        exit_codes = []
        for node in self.exec_nodes:
            ssh_command = ['ssh']
            ssh_command.append(node['ip_address'])
            ssh_command.append('-t')
            ssh_command.extend(['-o', 'UserKnownHostsFile=/dev/null'])
            ssh_command.extend(['-o', 'StrictHostKeyChecking=no'])
            ssh_command.extend(['-l', 'root'])
            ssh_command.extend(args)
            exit_codes.append(subprocess.call(ssh_command))
        self.exit_codes = exit_codes
