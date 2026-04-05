#!/usr/bin/env bash

set -euo pipefail
set -x

export HOME_GITHUB=$(pwd)
export ISO_COUNTRY_CODE=ru

# From my repository ipranges IP-address
download_ip() {
    curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://www.ipdeny.com/ipblocks/data/countries/$ISO_COUNTRY_CODE.zone https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/main/lifestream/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/ORI/GRCHC/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/qrator/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/yandex-all/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/vkontakte/ipv4_smart.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/avito/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/megafon/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/rostelecom/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/beeline-all/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/mts-all/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/pakt/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/skynet/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/inet-lan/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/whitelist/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/beget/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/NDNS/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/obit/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/rascom/ipv4_merged.txt https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/refs/heads/main/rugov/ipv4_merged.txt
}

# From my repository ipranges domain (if any)
download_domain() {
    curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/hxehex/russia-mobile-internet-whitelist/refs/heads/main/whitelist.txt
}

download_ip "${ISO_COUNTRY_CODE}" > "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/ipv4.txt
download_domain "${ISO_COUNTRY_CODE}" >> "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/domain.txt

if [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/ipv4.txt" ]] && [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain.txt" ]] && [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain_wildcard.txt" ]]; then
    jq -n \
        --slurpfile domain_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain.txt") \
        --slurpfile domain_wildcard_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain_wildcard.txt") \
        --slurpfile ip_cidr_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/ipv4.txt") '
{
  version: 1,
  rules: [
    {
      domain: $domain_data,
      domain_suffix: $domain_wildcard_data,
      ip_cidr: $ip_cidr_data
    }
  ]
    }' > "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/${ISO_COUNTRY_CODE}.json"
elif [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/ipv4.txt" ]] && [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain.txt" ]]; then
    jq -n \
        --slurpfile domain_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain.txt") \
        --slurpfile ip_cidr_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/ipv4.txt") '
{
  version: 1,
  rules: [
    {
      domain: $domain_data,
      ip_cidr: $ip_cidr_data
    }
  ]
    }' > "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/${ISO_COUNTRY_CODE}.json"

elif [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/ipv4.txt" ]] && [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain_wildcard.txt" ]]; then
    jq -n \
        --slurpfile domain_wildcard_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain_wildcard.txt") \
        --slurpfile ip_cidr_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/ipv4.txt") '
{
  version: 1,
  rules: [
    {
      domain_suffix: $domain_wildcard_data,
      ip_cidr: $ip_cidr_data
    }
  ]
    }' > "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/${ISO_COUNTRY_CODE}.json"

elif [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain.txt" ]] && [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain_wildcard.txt" ]]; then
    jq -n \
        --slurpfile domain_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain.txt") \
        --slurpfile domain_wildcard_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain_wildcard.txt") '
{
  version: 1,
  rules: [
    {
      domain: $domain_data,
      domain_suffix: $domain_wildcard_data
    }
  ]
    }' > "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/${ISO_COUNTRY_CODE}.json"
elif [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/ipv4.txt" ]]; then
    jq -n \
        --slurpfile ip_cidr_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/ipv4.txt") '
{
  version: 1,
  rules: [
    {
      ip_cidr: $ip_cidr_data
    }
  ]
    }' > "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/${ISO_COUNTRY_CODE}.json"
elif [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain.txt" ]]; then
    jq -n \
        --slurpfile domain_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain.txt") '
{
  version: 1,
  rules: [
    {
      domain: $domain_data
    }
  ]
    }' > "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/${ISO_COUNTRY_CODE}.json"
elif [[ -f "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain_wildcard.txt" ]]; then
    jq -n \
        --slurpfile domain_wildcard_data <(jq -R . "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/domain_wildcard.txt") '
{
  version: 1,
  rules: [
    {
      domain_suffix: $domain_wildcard_data
    }
  ]
    }' > "${HOME_GITHUB}/country/${ISO_COUNTRY_CODE}/${ISO_COUNTRY_CODE}.json"
else
    echo "❗ Files not found!"
fi


# Create srs rules for Sing-Box
sing-box rule-set compile "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/"${ISO_COUNTRY_CODE}".json

rm -f "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/*.{zst,zip}

# Compression json file to save HDD space and in order to meet the GitHub limits for a free account.
cat "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/"${ISO_COUNTRY_CODE}".json | zstd -o "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/"${ISO_COUNTRY_CODE}".json.zst && rm -f "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/"${ISO_COUNTRY_CODE}".json "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/domain.txt "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/ipv4.txt

# Compress srs rules for husi in zip (Android-client)
cd "${HOME_GITHUB}"/country/"${ISO_COUNTRY_CODE}"/ && zip -9 "${ISO_COUNTRY_CODE}".zip "${ISO_COUNTRY_CODE}".srs
