FROM finntech/java8:8u112-2

ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 0
ENV TOMCAT_PATCH_VERSION 73

ENV TOMCAT_VERSION $TOMCAT_MAJOR_VERSION.$TOMCAT_MINOR_VERSION.$TOMCAT_PATCH_VERSION

ENV CATALINA_HOME /opt/tomcat${TOMCAT_MAJOR_VERSION}
ENV PATH $CATALINA_HOME/bin:$PATH

RUN curl -s http://apache.uib.no/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MAJOR_VERSION}.${TOMCAT_MINOR_VERSION}.${TOMCAT_PATCH_VERSION}/bin/apache-tomcat-${TOMCAT_MAJOR_VERSION}.${TOMCAT_MINOR_VERSION}.${TOMCAT_PATCH_VERSION}.tar.gz \
 | tar -xzf - -C /opt \
 && ln -s /opt/apache-tomcat-${TOMCAT_MAJOR_VERSION}.${TOMCAT_MINOR_VERSION}.${TOMCAT_PATCH_VERSION} /opt/tomcat${TOMCAT_MAJOR_VERSION} \
 && rm -rf ${CATALINA_HOME}/webapps/* \
         ${CATALINA_HOME}/bin/*.bat

ADD serverinfo.jar ${CATALINA_HOME}/lib/serverinfo.jar
ADD server.xml ${CATALINA_HOME}/conf/
ADD context.xml ${CATALINA_HOME}/conf/

ADD deploy-and-run.sh ${CATALINA_HOME}/bin/
RUN chmod 755 ${CATALINA_HOME}/bin/deploy-and-run.sh

WORKDIR $CATALINA_HOME

EXPOSE 8080

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/opt/tomcat7/bin/deploy-and-run.sh" ]
