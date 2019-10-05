FROM centos:7


ENV RUBY_DIR /ruby
ENV RUBY_VERSION 2.5.0
ENV RUBY_INSTALL $RUBY_DIR/$RUBY_VERSION

RUN rpm -Uvh \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum update -y && \
    yum install -y make which wget tar git \
    gcc patch readline-devel zlib-devel      \
    libyaml-devel libffi-devel openssl-devel \
    gdbm-devel ncurses-devel libxml-devel bzip2

RUN cd /usr/src && \
    git clone https://github.com/sstephenson/ruby-build.git && \
    ./ruby-build/install.sh && \
    mkdir -p $RUBY_INSTALL && \
    /usr/local/bin/ruby-build $RUBY_VERSION $RUBY_INSTALL && \
    rm -rf /usr/src/ruby-build

ENV PATH $RUBY_INSTALL/bin:$PATH


# PDQ
# --------------------------------------------------------------------------------------------------------------
#
ADD libs/. /pdq

# Perl
RUN yum -y install perl-devel perl-ExtUtils-Embed
RUN cd /pdq && tar -zxvf pdq-6.2.0-pl.tar.gz && mv pdq-6.2.0 pdq-6.2.0-pl && cd pdq-6.2.0-pl && perl Makefile.PL && make && make install

# Python
RUN yum -y install python-devel
RUN cd /pdq && tar -zxvf pdq-6.2.0-py.tar.gz && mv pdq-6.2.0 pdq-6.2.0-py && cd pdq-6.2.0-py && python setup.py install

# R
RUN yum -y install epel-release
RUN yum -y install R --nogpgcheck
RUN cd /pdq && tar -zxvf pdq-6.2.0-r.tar.gz && mv pdq pdq-6.2.0-r #&& cd pdq-6.2.0-r && perl Makefile.PL && make && make install

# UI
# --------------------------------------------------------------------------------------------------------------
#
WORKDIR /app
ADD app/Gemfile* /app/
RUN gem install bundler -v '1.17.3'
RUN bundle install
ADD app/. /app
RUN sed -i "s/Version: 0000/Build: $(date)/g" /app/public/index.html

USER nobody

ENTRYPOINT ["ruby", "app.rb"]
