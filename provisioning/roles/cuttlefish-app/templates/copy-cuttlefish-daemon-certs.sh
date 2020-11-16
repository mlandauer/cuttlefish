#!/bin/sh

set -e

# Make sure the certificate and private key files are
# never world readable, even just for an instant while
# we're copying them
umask 077

cp "$RENEWED_LINEAGE/fullchain.pem" /srv/www/shared/
cp "$RENEWED_LINEAGE/privkey.pem" /srv/www/shared/

# Apply the proper file ownership and permissions for
# the daemon to read its certificate and key.
chown deploy /srv/www/shared/fullchain.pem /srv/www/shared/privkey.pem
chmod 400 /srv/www/shared/fullchain.pem /srv/www/shared/privkey.pem

systemctl restart cuttlefish-smtp.target > /dev/null
