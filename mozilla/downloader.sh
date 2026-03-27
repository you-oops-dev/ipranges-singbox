#!/usr/bin/env bash

set -euo pipefail
set -x

export HOME_GITHUB=$(pwd)
export NAME_SERVICE=mozilla

# From my repository ipranges IP-address
download_ip() {
    curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/main/"$1"/ipv4_merged.txt
}

# From my repository ipranges domain (if any)
download_domain() {
    curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/mozilla \
                                                         https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Mozilla/Mozilla.list
}

#download_ip "${NAME_SERVICE}" > "${HOME_GITHUB}"/"${NAME_SERVICE}"/ipv4.txt
download_domain "${NAME_SERVICE}" | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed '/IP-CIDR/d' | sed '/@/d' | sed 's/full://g' | sed '/:/d' | sed 's/DOMAIN,//g' | sed '/DOMAIN-KEYWORD/d' | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed 's/full://g' | sed '/IP-CIDR/d' | sed '/@/d' | sed '/:/d' | sed '/.cn/d' | sort | uniq > "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt

if [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/ipv4.txt" ]] && [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/domain.txt" ]] && [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt" ]]; then
    jq -n \
        --slurpfile domain_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/domain.txt") \
        --slurpfile domain_wildcard_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt") \
        --slurpfile ip_cidr_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/ipv4.txt") '
{
  version: 1,
  rules: [
    {
      domain: $domain_data,
      domain_suffix: $domain_wildcard_data,
      ip_cidr: $ip_cidr_data
    }
  ]
    }' > "${HOME_GITHUB}/${NAME_SERVICE}/${NAME_SERVICE}.json"
elif [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/ipv4.txt" ]] && [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/domain.txt" ]]; then
    jq -n \
        --slurpfile domain_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/domain.txt") \
        --slurpfile ip_cidr_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/ipv4.txt") '
{
  version: 1,
  rules: [
    {
      domain: $domain_data,
      ip_cidr: $ip_cidr_data
    }
  ]
    }' > "${HOME_GITHUB}/${NAME_SERVICE}/${NAME_SERVICE}.json"

elif [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/ipv4.txt" ]] && [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt" ]]; then
    jq -n \
        --slurpfile domain_wildcard_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt") \
        --slurpfile ip_cidr_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/ipv4.txt") '
{
  version: 1,
  rules: [
    {
      domain_suffix: $domain_wildcard_data,
      ip_cidr: $ip_cidr_data
    }
  ]
    }' > "${HOME_GITHUB}/${NAME_SERVICE}/${NAME_SERVICE}.json"

elif [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/domain.txt" ]] && [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt" ]]; then
    jq -n \
        --slurpfile domain_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/domain.txt") \
        --slurpfile domain_wildcard_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt") '
{
  version: 1,
  rules: [
    {
      domain: $domain_data,
      domain_suffix: $domain_wildcard_data
    }
  ]
    }' > "${HOME_GITHUB}/${NAME_SERVICE}/${NAME_SERVICE}.json"
elif [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/ipv4.txt" ]]; then
    jq -n \
        --slurpfile ip_cidr_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/ipv4.txt") '
{
  version: 1,
  rules: [
    {
      ip_cidr: $ip_cidr_data
    }
  ]
    }' > "${HOME_GITHUB}/${NAME_SERVICE}/${NAME_SERVICE}.json"
elif [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/domain.txt" ]]; then
    jq -n \
        --slurpfile domain_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/domain.txt") '
{
  version: 1,
  rules: [
    {
      domain: $domain_data
    }
  ]
    }' > "${HOME_GITHUB}/${NAME_SERVICE}/${NAME_SERVICE}.json"
elif [[ -f "${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt" ]]; then
    jq -n \
        --slurpfile domain_wildcard_data <(jq -R . "${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt") '
{
  version: 1,
  rules: [
    {
      domain_suffix: $domain_wildcard_data
    }
  ]
    }' > "${HOME_GITHUB}/${NAME_SERVICE}/${NAME_SERVICE}.json"
else
    echo "❗ Files not found!"
fi


# Create srs rules for Sing-Box
sing-box rule-set compile "${HOME_GITHUB}"/"${NAME_SERVICE}"/"${NAME_SERVICE}".json

rm -f "${HOME_GITHUB}"/"${NAME_SERVICE}"/*.{zst,zip}

# Compression json file to save HDD space and in order to meet the GitHub limits for a free account.
cat "${HOME_GITHUB}"/"${NAME_SERVICE}"/"${NAME_SERVICE}".json | zstd -o "${HOME_GITHUB}"/"${NAME_SERVICE}"/"${NAME_SERVICE}".json.zst && rm -f "${HOME_GITHUB}"/"${NAME_SERVICE}"/"${NAME_SERVICE}".json "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt "${HOME_GITHUB}"/"${NAME_SERVICE}"/ipv4.txt

# Compress srs rules for husi in zip (Android-client)
cd "${HOME_GITHUB}"/"${NAME_SERVICE}"/ && zip -9 ./"${NAME_SERVICE}".zip ./"${NAME_SERVICE}".srs
