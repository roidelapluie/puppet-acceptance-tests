*** Settings ***
Library             ../lib/DuffyLibrary.py
Resource            ../lib/basic.robot

*** Keywords ***
I fetch the sources
    I successfully run   spectool    -g  -C  ws  ws/%{SPECFILE}.spec

I run rpmbuild
    I successfully run   rpmbuild    --define    "_topdir /root"     --define    "_sourcedir ws"  -bs     ws/%{SPECFILE}.spec

I make the specfile unique
    I run locally  sed  s/^Release:.*/Release: %{RELEASE}/  -i  %{WORKSPACE}/%{SPECFILE}.spec
    I run locally  sed  /Release: %{RELEASE}/aProvides: facter-git-commit(%{ghprbActualCommit})  -i  %{WORKSPACE}/%{SPECFILE}.spec
    I run locally  sed  /Release: %{RELEASE}/aProvides: facter-pull-request(%{ghprbPullId})  -i  %{WORKSPACE}/%{SPECFILE}.spec
    I run locally  sed  /Release: %{RELEASE}/aProvides: facter-pull-request-build-id(%{RELEASE})  -i  %{WORKSPACE}/%{SPECFILE}.spec
    I run locally  sed  /Release: %{RELEASE}/aEpoch: %{BUILD_NUMBER}  -i  %{WORKSPACE}/%{SPECFILE}.spec

I build a SRPM from the specfile
    I install   rpmdevtools
    I install   rpm-build
    I fetch the sources
    I run rpmbuild

I copy the workspace
    I install   rsync
    I rsync the workspace

I prepare the SRPM
    On the Duffy node
    I copy the workspace
    I build a SRPM from the specfile
    I fetch the SRPM

I scratch build the spec file in CBS
    I prepare the SRPM
    ${filename} =   Get Glob File  %{WORKSPACE}/*.src.rpm
    I run locally   cbs  build  --wait  --scratch  %{BUILDTARGET}   ${filename}
    I run locally   rm   ${filename}
    I run   rm -rf SRPMS

I build the spec file in CBS
    I prepare the SRPM
    ${filename} =   Get Glob File  %{WORKSPACE}/*.src.rpm
    I try to run locally   cbs  add-pkg  --owner  roidelapluie  %{BUILDTAG}-candidate  %{SPECFILE}
    I run locally   cbs  build  --wait  %{BUILDTARGET}   ${filename}
    I run locally   rm   ${filename}
    I run   rm -rf SRPMS

I install the package from a pull request
    I add a CBS yum repo    %{BUILDTAG}-candidate
    I successfully run  yum  --setopt  metadata_expire=0  install  -y  "%{PACKAGE}-pull-request-build-id(%{RELEASE})"

I install the package from candidate
    I add a CBS yum repo    %{BUILDTAG}-candidate
    I successfully run  yum  --setopt  metadata_expire=0  install  -y  "%{PACKAGE}"

I install the package
    Run Keyword If  'RELEASE' in os.environ     I install the package from a pull request
    Run Keyword If  'RELEASE' in os.environ     I install the package from candidate
