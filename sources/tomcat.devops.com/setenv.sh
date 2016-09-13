 export CATALINA_OPTS="$CATALINA_OPTS\
  -Dcom.sun.management.jmxremote\
  -Dcom.sun.management.jmxremote.authenticate=false\
  -Dcom.sun.management.jmxremote.ssl=false\
  -Djava.rmi.server.hostname=192.168.144.20"
CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.port=12345"
CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote.rmi.port=12345"
