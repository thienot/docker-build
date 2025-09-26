#!/bin/sh

echo "⌛ Waiting for MySQL to be ready..."
until nc -z -v -w30 mysql 3306
do
  echo "⏳ Waiting for database connection..."
  sleep 3
done
echo "✅ MySQL is up!"

# Cài composer nếu chưa có
if [ ! -f "/usr/local/bin/composer" ]; then
  echo "🎼 Installing Composer..."
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  chmod +x /usr/local/bin/composer
fi

cd /var/www/html

# Sửa .env Laravel trên host
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=adminweb/" .env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=V@84gLw9fpTqU3!/" .env
sed -i "s/^DB_DATABASE=.*/DB_DATABASE=webphim_tutorial/" .env
sed -i "s/^DB_HOST=.*/DB_HOST=mysql/" .env
echo "✅ Sửa .env Laravel"

rm -rf vendor composer.lock
echo "🗑️ Đã xóa vendor/ và composer.lock"


# Cài thư viện nếu chưa có
if [ ! -d "vendor" ]; then
    echo "📦 Installing Composer dependencies..."
    composer install --no-dev --optimize-autoloader
fi

# Sinh APP_KEY nếu chưa có
if ! grep -q "^APP_KEY=" .env || [ -z "$(grep ^APP_KEY= .env | cut -d'=' -f2)" ]; then
    echo "🔐 Generating application key..."
    php artisan key:generate
fi
# Clear & cache
echo "🧹 Clearing and caching Laravel config..."
php artisan config:clear
php artisan config:cache
php artisan route:clear
php artisan route:cache
php artisan view:clear
php artisan view:cache

# Chạy migrate
# echo "🧬 Running database migrations..."
# php artisan migrate --force


# Phân quyền
echo "🔒 Setting permissions..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data /var/www/html/public
chmod -R 755 /var/www/html/public
# Chạy PHP-FPM
exec php-fpm
