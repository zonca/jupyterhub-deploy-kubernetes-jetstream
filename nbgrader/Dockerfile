FROM quay.io/jupyter/scipy-notebook:2025-11-10

RUN pip install --no-cache-dir nbgrader ngshare-exchange

# Configure nbgrader to use ngshare
RUN mkdir -p /etc/jupyter && \
    printf '%s\n' \
      "from ngshare_exchange import configureExchange" \
      "c = get_config()" \
      "configureExchange(c, 'http://ngshare.jhub.svc.cluster.local:8080/services/ngshare')" \
      "c.CourseDirectory.course_id = 'COURSE_ID'" \
      > /etc/jupyter/nbgrader_config.py
