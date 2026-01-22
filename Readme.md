# Setup
You need to create this files, with the passwords. Here just an example, what needs to be created. **Don't use this passwords, they are not save!**

```bash
# Create secrets directory
mkdir -p secrets
chmod 700 secrets

# MariaDB / WordPress database secrets
echo "db-test" > secrets/db_name
echo "db-test-user" > secrets/db_user
echo "change-me" > secrets/db_password

# WordPress admin user (administrator role)
echo "wp" > secrets/wp_admin_user
echo "change-me" > secrets/wp_admin_password
echo "wp@wp.com" > secrets/wp_admin_email

# WordPress normal user (subscriber role)
echo "wp-user" > secrets/wp_user_name
echo "change-me" > secrets/wp_user_password
echo "user@user.com" > secrets/wp_user_email

```

# Wordpress Page
lseeger.42.fr
localhost

# Wordpress Management Page
lseeger.42.fr/wp-admin
lseeger.42.fr/wp-login
