#!/usr/bin/env bash

#set -euo pipefail
#set -x

export HOME_GITHUB=$(pwd)
export NAME_SERVICE=youtube

# From my repository ipranges IP-address
download_ip() {
    curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/main/"$1"/ipv4_merged.txt
}

# From my repository ipranges domain (if any)
download_domain() {
    curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/main/"$1"/domain.txt https://raw.githubusercontent.com/antonme/ipnames/refs/heads/master/dns-youtube.txt https://raw.githubusercontent.com/bol-van/zapret-win-bundle/refs/heads/master/zapret-winws/files/list-youtube.txt https://raw.githubusercontent.com/antonme/ipnames/master/ext-dns-youtube.txt https://raw.githubusercontent.com/bol-van/zapret-win-bundle/refs/heads/master/zapret-winws/files/list-youtube.txt https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/youtube.lst
}

download_ip "${NAME_SERVICE}" > "${HOME_GITHUB}"/"${NAME_SERVICE}"/ipv4.txt
download_domain "${NAME_SERVICE}" > "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt

#Отфильтровать домена дополнительно
echo "img.youtube.com
ggpht.com
ytimg.com
youtu.be
youtubei.googleapis.com
googleusercontent.com
yt3.ggpht.com
googlevideo.com
gstatic.com
googleapis.com
googleusercontent.com
youtube.com
sponsor.ajay.app
sponsorblock.hankmccord.dev
returnyoutubedislike.com
returnyoutubedislikeapi.com" >> "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
dos2unix "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
sort "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt | uniq | sponge "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt
# Prepare domain
# Delete subdomain in file
cat "${HOME_GITHUB}"/"${NAME_SERVICE}"/domain.txt | grep -vEe '(.gvt1.com|.uber.com|.ytimg.com|.google.com|.withgoogle.com|.googleusercontent.com|.metric.gstatic.com|.googleapis.com|.ggpht.com)$' > ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt
sort -h ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt | uniq | sed '/kellykawase/d' | sed '/hatenablog.co/d' | sed '/blogspot/d' | sed '/githubusercontent/d' | sed '/appspot/d' | sed '/kilatiron/d' | sed '/.ru$/d' | sed '/.co$/d' | sed '/.download$/d' | sed '/.yolasite.com$/d' | sed '/.youtube$/d' | sed '/.info$/d' | sed '/.me$/d' | sed '/.be$/d' | sed '/.net$/d' | sed '/.io$/d' | sed '/.ua$/d' | sed '/.cn$/d' | sort | sponge ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt
sed -i '/watchv/d' ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt
cp -fv ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt ${HOME_GITHUB}/${NAME_SERVICE}/domain.txt

sed -i 's/^www.//g' ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt
sort ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt | uniq | sponge ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt
sed -i 's/^/./' ${HOME_GITHUB}/${NAME_SERVICE}/domain_wildcard.txt


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
