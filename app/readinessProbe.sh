#!/bin/sh

namespace=${NAMESPACE:-default}
service=${SERVICE}
refresh=${REFRESH:-15}
url=${MASTER_URL:-"https://kubernetes.default.svc"}

cacert=${SA_CACERT:-"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"}
token="$(cat ${SA_TOKEN:-"/var/run/secrets/kubernetes.io/serviceaccount/token"})"

until [ \
    $(curl -sS --cacert $cacert --header "Authorization: Bearer $token" \
        ${url}/api/v1/namespaces/${namespace}/endpoints/${service} \
        | jq -r '.subsets[].addresses | length') -gt 0 \
    ]
do
    echo "waiting for ${service}"
    sleep ${refresh}
done