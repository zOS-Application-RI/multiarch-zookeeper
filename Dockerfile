FROM ibm-semeru-runtimes:open-11-jre-jammy
ENV ZOOKEEPER_VERSION 3.9.3

RUN set -eux ; \
    apt-get update ; \
    apt-get upgrade -y ; \
    apt-get install -y --no-install-recommends jq net-tools curl wget ; \
### BEGIN docker for CI tests
    apt-get install -y --no-install-recommends gnupg lsb-release ; \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg ; \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null ; \
    apt-get update ; \
    apt-get install -y --no-install-recommends docker-ce-cli ; \
    apt remove -y gnupg lsb-release ; \
    apt clean ; \
    apt autoremove -y ; \
    apt -f install ; 
### END docker for CI tests
#Download Zookeeper
RUN wget -q http://mirror.vorboss.net/apache/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz && \
wget -q https://www.apache.org/dist/zookeeper/KEYS 
# && \
# wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.asc && \
# wget -q https://www.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.md5

# #Verify download
# RUN md5sum -c zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.md5 && \
# gpg --import KEYS && \
# gpg --verify zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz.asc

#Install
RUN tar -xzf apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -C /opt

#Configure
RUN mv /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/conf/zoo_sample.cfg /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/conf/zoo.cfg

# ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV ZK_HOME /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin
RUN sed  -i "s|/tmp/zookeeper|$ZK_HOME/data|g" $ZK_HOME/conf/zoo.cfg; mkdir $ZK_HOME/data

ADD start-zk.sh /usr/bin/start-zk.sh 
EXPOSE 2181 2888 3888

WORKDIR /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin
VOLUME ["/opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/conf", "/opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/data"]

# CMD /usr/sbin/sshd && bash /usr/bin/start-zk.sh
CMD ["bash", "/usr/bin/start-zk.sh"]
