.PHONY: site clean secrets mkdir_secrets ${SECRET_TARGETS} certreq

SECRETS_DIR = secret

SECRET_TARGETS = ${PLAIN_SECRETS} \
	constellation_cert \

PLAIN_SECRETS = connstellation_dbpassword \
	constellation_secret_key

secrets: mkdir_secrets ${SECRET_TARGETS}
	@tput setaf 1 && echo "Make sure you don't commit the secrets/ directory!" && tput sgr0

mkdir_secrets:
	mkdir -pm 0700 ${SECRETS_DIR}

${PLAIN_SECRETS}:
	export LC_CTYPE=C; tr -dc '!-~' < /dev/urandom | fold -w 32 | head -n 1 > ${SECRETS_DIR}/$@

certreq:
	openssl genrsa -out ${SECRETS_DIR}/${role}_key.pem 4096
	cp cert.conf ${role}_cert.conf
	echo "CN = ${fqdn}" >> ${role}_cert.conf
	openssl req -new -config ${role}_cert.conf -key ${SECRETS_DIR}/${role}_key.pem -out ${SECRETS_DIR}/${role}_csr.pem
	rm ${role}_cert.conf
	@tput setaf 1 0 0 && echo "Follow the steps at https://www.utdallas.edu/infosecurity/DigitalCertificates_SSL.html and put the resulting key at ${SECRETS_DIR}/${role}_cert.pem" && tput sgr0

constellation_cert:
	${MAKE} role=constellation fqdn=polaris.utdallas.edu certreq
