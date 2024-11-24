# Ensure Docker's official GPG key is added
docker_gpg_key:
  file.managed:
    - name: /etc/apt/keyrings/docker.asc
    - source: https://download.docker.com/linux/debian/gpg
    - mode: 0644
    - skip_verify: True

# Generate Docker repository file
docker_repository:
  cmd.run:
    - name: echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    - require:
      - file: docker_gpg_key

# Update package cache
update_package_cache:
  pkg.uptodate:
    - refresh: True

# Install Docker packages
docker_install:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    - require:
      - pkg: update_package_cache

# Ensure Docker service is enabled and running
docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker_install

# Add `nougatbyte` to the `docker` group
docker_group:
  user.present:
    - name: nougatbyte
    - groups:
      - docker

# Install additional packages
additional_packages:
  pkg.installed:
    - pkgs:
      - vim
      - tree
      - htop
      - btop
      - wget
      - curl
      
# Create directories
create_directories:
  file.directory:
    - name: /srv/pterodactyl/wings/config
    - user: nougatbyte
    - group: nougatbyte
    - mode: 755
    - require:
      - user: nougatbyte

  file.directory:
    - name: /srv/pterodactyl/panel/appvar
    - user: nougatbyte
    - group: nougatbyte
    - mode: 755
    - require:
      - user: nougatbyte

  file.directory:
    - name: /srv/pterodactyl/panel/nginx
    - user: nougatbyte
    - group: nougatbyte
    - mode: 755
    - require:
      - user: nougatbyte

  file.directory:
    - name: /srv/pterodactyl/panel/logs
    - user: nougatbyte
    - group: nougatbyte
    - mode: 755
    - require:
      - user: nougatbyte

# create docker-compose file
docker_compose:
  file.managed:
    - name: /srv/pterodactyl/docker-compose.yml
    - source: salt://docker-compose.yml


# Start Docker services in detached mode
start_docker_services:
  cmd.run:
    - name: docker compose up -d
    - cwd: /srv/pterodactyl/