FROM jccwebservicesregistry.azurecr.io/source/drupal-nginx-fpm:1.3

ENV GIT_REPO "https://github.com/JudicialCouncilOfCalifornia/trialcourt"
ENV GIT_BRANCH "master"

RUN rm -rf ${DRUPAL_BUILD}
RUN mkdir -p ${DRUPAL_BUILD}

RUN git clone ${GIT_REPO} --branch ${GIT_BRANCH} repobuild
RUN rm -rf repobuild/.git
RUN cp -R repobuild/* ${DRUPAL_BUILD}/
RUN rm -rf repobuild

WORKDIR ${DRUPAL_BUILD}
RUN composer install
RUN scripts/theme.sh -a