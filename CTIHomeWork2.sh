#!/bin/bash

# Kontrol ve Başlangıç

if [ $# -ne 1 ]; then
  echo "Kullanım: CTIHomeWork2.sh <alan_adı>"
  exit 1
fi

alan_adi=$1

# IP Adresi Bulma --dig aracı 
ip_adresi=`dig +short A $alan_adi | awk '{print $1}'`

if [ -z "$ip_adresi" ]; then
  echo "IP adresi bulunamadı."
  exit 1
fi

# Whois Sorgusu -- whois kullanıldı --
whois_bilgisi=`whois $alan_adi`

# Portla Taraması --nmap kullanıldı --
nmap_taramasi=`nmap -Pn -A -v -T4 -p 1-100 $ip_adresi | grep -oE '([0-9]+)/tcp.*open'`

# Google Arama Sonuçları --dork kullanımı -- 
google_arama_linkleri=`google dork:"$alan_adi" filetype:xls | grep -oP 'https?://[^"]+'`

# Site İçi Bağlantılar -- wget aracı -- 
site_iceri_linkleri=`wget -O -q $alan_adi | grep -oP '<a href="(.*?)"' | sed 's/[^"]*"\|^"|>$//g'`

# firewall tespiti -- wafw00f aracı --
firewall_tespiti=`wafw00f $alan_adi`


# Çıktı dosya adı

dosya="output.txt"

# site içi bağlantı kısmında sonuç alamadım.
# 
echo "## Domain Bilgileri: $alan_adi" > $dosya
echo "firewall tespit Bilgileri: $firewall_tespiti" >> $dosya
echo "IP Adresi: $ip_adresi" >> $dosya
echo "Whois Bilgisi:" >> $dosya
echo "$whois_bilgisi" >> $dosya
echo "Açık Portlar:" >> $dosya
echo "$nmap_taramasi" >> $dosya
echo "Google Arama Sonuçları (Excel):" >> $dosya
for link in $google_arama_linkleri; do
  echo "$link" >> $dosya
done
echo "Site İçi Bağlantılar:" >> $dosya
for link in $site_iceri_linkleri; do
  echo "$link" >> $dosya
done

echo "Bilgiler $dosya dosyasına kaydedildi."
