# Odoo image with your custom addons baked in.
FROM odoo:17

ENV ODOO_RC=/etc/odoo/odoo.conf
USER root

RUN mkdir -p /mnt/extra-addons/custom-addons \
    && chown -R odoo:odoo /mnt/extra-addons

# Your own community/custom addons (you own these).
COPY --chown=odoo:odoo custom-addons/ /mnt/extra-addons/custom-addons/

# -------------------------------------------------------------------------
# ODOO ENTERPRISE IS PROPRIETARY, LICENSED SOFTWARE.
# Do NOT commit enterprise addon code to a public repository — that is a
# license violation. If you have an Enterprise license, supply the addons
# at build time in YOUR OWN private build and add the addons path to
# odoo.conf (addons_path). The lines below are intentionally left out.
#
# COPY --chown=odoo:odoo enterprise-addons/ /mnt/extra-addons/enterprise-addons/
# -------------------------------------------------------------------------

RUN test -d /mnt/extra-addons/custom-addons

USER odoo
EXPOSE 8069 8072
