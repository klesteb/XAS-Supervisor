Name:           perl-XAS-XXXX
Version:        0.01
Release:        1%{?dist}
Summary:        A set of processes to manage spool files
License:        Artistic 2.0
Group:          Development/Libraries
URL:            http://scm.kesteb.us/git/XAS-XXXX/trunk/
Source0:        XAS-XXXX-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl(Module::Build)
BuildRequires:  perl(Test::More)
Requires:       perl(XAS) >= 0.12
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%define _initd      %{_sysconfdir}/rc.d/init.d
%define _sysconfig  %{_sysconfdir}/sysconfig
%define _logrotated %{_sysconfdir}/logrotate.d
%define _profiled   %{_sysconfdir}/profile.d
%define _xasconf    %{_sysconfdir}/xas

%if 0%{?rhel} == 6
%define _mandir /usr/local/share/man
%{?filter_setup: %{?perl_default_filter} }
%filter_from_requires /Win32/d
%filter_from_provides /Win32/d
%filter_setup
%endif

%description
A set of processes to manage spool files

%prep
%setup -q -n XAS-XXXX-%{version}

%if 0%{?rhel} == 5
cat << \EOF > %{name}-prov
#!/bin/sh
%{__perl_provides} $* | sed -e '/Win32/d'
EOF
%global __perl_provides %{_builddir}/XAS-XXXX-%{version}/%{name}-prov
chmod +x %{__perl_provides}
cat << \EOF > %{name}-req
#!/bin/sh
%{__perl_requires} $* | sed -e '/Win32/d'
EOF
%global __perl_requires %{_builddir}/XAS-XXXX-%{version}/%{name}-req
chmod +x %{__perl_requires}
%endif

%build
%{__perl} Build.PL --installdirs vendor
./Build

%install
rm -rf $RPM_BUILD_ROOT

./Build install destdir=$RPM_BUILD_ROOT create_packlist=0
./Build redhat destdir=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;
%{_fixperms} $RPM_BUILD_ROOT/*

%check
./Build test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes README perl-XXXX.spec
%{perl_vendorlib}/*
%config(noreplace) %{_sysconfig}/xxxx
%config(noreplace) %{_logrotated}/xxxx
%config(noreplace) %{_initd}/xxxx
%config(noreplace) %{_xasconf}/xxxx
%{_mandir}/*
%{_sbindir}/*
%{_bindir}/*

%changelog
* Tue Mar 18 2014 "kesteb <kevin@kesteb.us>" 0.01-1
- Created for the v0.01 release.
