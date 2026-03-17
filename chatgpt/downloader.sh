#!/usr/bin/env bash

set -euo pipefail
set -x

export HOME_GITHUB=$(pwd)
export NAME_SERVICE=chatgpt

# From my repository ipranges IP-address
download_ip() {
    curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/main/"$1"/ipv4_merged.txt
}

# From my repository ipranges domain (if any)
download_domain() {
    curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/main/"$1"/domain.txt
}

download_ip "${NAME_SERVICE}" > "${HOME_GITHUB}"/"${NAME_SERVICE}"/ipv4.txt
#download_domain "${NAME_SERVICE}" > "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt

curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/antonme/ipnames/master/dns-openai.txt >> "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/antonme/ipnames/master/ext-dns-openai.txt >> "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
echo 'ab.chatgpt.com
api.openai.com
arena.openai.com
auth.openai.com
auth0.openai.com
beta.api.openai.com
beta.openai.com
blog.openai.com
cdn.oaistatic.com
cdn.openai.com
community.openai.com
contest.openai.com
debate-game.openai.com
discuss.openai.com
files.oaiusercontent.com
gpt3-openai.com
gym.openai.com
help.openai.com
ios.chat.openai.com
jukebox.openai.com
labs.openai.com
microscope.openai.com
oaistatic.com
openai.com
openai.fund
openai.org
platform.api.openai.com
platform.openai.com
spinningup.openai
chat.openai.com
chatgpt.com
featureassets.org
cdnjs.cloudflare.com
cdn.auth0.com
prodregistryv2.org' >> "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
dos2unix "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
sort "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt | uniq | sponge "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
# Prepare domain
# Delete subdomain in file
cat "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt | grep -vEe '(.openai.com|.openai.org|.openai.com.cdn.cloudflare.net|.oaistatic.com|.chatgpt.com)$' | sed '/.ua/d' | sponge "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
sort -h "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt | uniq | sponge "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt

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
