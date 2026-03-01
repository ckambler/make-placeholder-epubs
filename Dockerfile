FROM php:8.2-apache

# Install required PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        zip \
        gd \
        fileinfo \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository (private fork — token passed at build time)
ARG GITHUB_TOKEN
WORKDIR /tmp
RUN git clone https://${GITHUB_TOKEN}@github.com/ckambler/make-placeholder-epubs.git

# Copy application files to web root
RUN cp -r /tmp/make-placeholder-epubs/* /var/www/html/ \
    && rm -rf /tmp/make-placeholder-epubs

# Create necessary directories with proper permissions
RUN mkdir -p /var/www/html/epubs \
    && touch /var/www/html/processed_isbns.txt \
    && touch /var/www/html/debug.log \
    && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

EXPOSE 80
