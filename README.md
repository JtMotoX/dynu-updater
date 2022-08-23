# Dynu DNS Updater
Dynu is a free DNS provider. This project is for those who use Dynu for DNS and have a dynamic IP. This updater will run on a schedule and will automatically update your DNS records to point to your new IP if your ISP changes your IP.

### Dynu Instructions
1. In Dynu, create a group (e.g. home)
1. In Dynu, set your DNS service to your group

### Server Instructions
1. Copy the [.env.sample](./.env.sample) file to [.env](./.env) and make necessary changes
1. *[Optional]* Edit the schedule in the [crontab](./build/crontab) file
1. Run the command ```docker-compose down && docker-compose up --build -d && docker-compose logs -f```

*Note: Check the container logs to make sure there are no errors. If you get any access errors, please correct them by changing the file permissions to 777.*
