FROM datastax/dse-server:6.8.9-ubi7

LABEL build_reason=use_diff_user

USER root

RUN groupadd --system --gid=1000 app \
    && useradd --system --no-log-init --gid app --uid=1000 app

COPY --chown=app:app entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && mv /opt/dse/resources/cassandra/conf /opt/dse/resources/cassandra/conf-template

VOLUME ["/var/lib/cassandra" "/var/lib/dsefs" "/var/lib/spark" "/var/log/cassandra" "/var/log/spark" "/opt/dse/resources/cassandra/conf"]

RUN (for x in /opt/dse /opt/dse/resources/cassandra/conf /var/lib/cassandra /var/lib/dsefs /var/lib/spark /var/log/cassandra /var/log/spark; do \
        chown -R app:app $x; done)

ENV DS_LICENSE=accept

USER app

