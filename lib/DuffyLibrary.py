#!/usr/bin/env python
# Copyright 2016 Julien Pivotto <roidelapluie@inuits.eu>
# Released under the GNU General Public licence v3 or later

import os
import subprocess
from cicoclient.wrapper import CicoWrapper
from robot.api.deco import keyword

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
        self.nodes, self.ssid = self.api.node_get(count=count, retry_count=10,
                                                  retry_interval=60, **kwargs)

    def release_the_duffy_nodes(self):
        if self.ssid:
            self.api.node_done(ssid=self.ssid)

    @single_node
    def on_the_duffy_node(self):
        self.exec_nodes = self.nodes

    def on_the_first_duffy_node(self):
        self.exec_nodes = self.nodes[0]

    def on_the_duffy_nodes(self):
        self.exec_nodes = self.nodes

    def i_run_locally(self, *args):
        subprocess.check_call(args)

    def i_run(self, *args):
        self._exec_ssh_command(*args)

    def i_copy_the_workspace(self):
        self.i_copy_the_workspace_to_a_duffy_node(0)

    def i_fetch_the_srpm(self):
        self._exec_sftp_command(self, 'ws/*.src.rpm', os.environ['WORKSPACE'])

    def i_copy_the_workspace_to_the_duffy_nodes(self, node):
        for node in self.exec_nodes.values():
            rsync_command = ['rsync']
            rsync_command.append(node['ip_address'])
            rsync_command.append('-e')
            rsync_command.append('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l root')
            rsync_command.append('-rlpt')
            rsync_command.append(os.environ['WORKSPACE'] + '/')
            rsync_command.append(node['ip_address'] + ':ws')
            subprocess.check_call(rsync_command)

    def it_returns(self, value):
        for code in self.exit_codes:
            assert code == int(value), 'Should have returned %s, returned %s.' % (code, value)

    def _exec_sftp_command(self, *args):
        exit_codes = []
        for node in self.exec_nodes.values():
            scp_command = ['scp']
            scp_command.extend(['-o', 'UserKnownHostsFile=/dev/null'])
            scp_command.extend(['-o', 'StrictHostKeyChecking=no'])
            scp_command.append('%s@%s' ('root', node['ip_address']))
            scp_command.extend(args)
            exit_codes.append(subprocess.check_call(scp_command))

    def _exec_ssh_command(self, *args):
        exit_codes = []
        for node in self.exec_nodes.values():
            ssh_command = ['ssh']
            ssh_command.append(node['ip_address'])
            ssh_command.append('-t')
            ssh_command.extend(['-o', 'UserKnownHostsFile=/dev/null'])
            ssh_command.extend(['-o', 'StrictHostKeyChecking=no'])
            ssh_command.extend(['-l', 'root'])
            ssh_command.extend(args)
            exit_codes.append(subprocess.call(ssh_command))
        self.exit_codes = exit_codes
