FROM nvcr.io/nvidia/tensorflow:22.04-tf2-py3
RUN pip install --no-cache-dir jupyterhub==3.0.0
RUN pip install --no-cache-dir --upgrade jupyterlab notebook jupyter_server

# Initialization of user copied from:
# https://github.com/jupyter/docker-stacks/blob/main/docker-stacks-foundation/Dockerfile

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions

ENV HOME="/home/${NB_USER}"

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
# hadolint ignore=SC2016
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER with name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    useradd -l -m -s /bin/bash -N -u "${NB_UID}" "${NB_USER}" && \
    chmod g+w /etc/passwd && \
    fix-permissions "${HOME}"

USER ${NB_UID}

WORKDIR "${HOME}"
