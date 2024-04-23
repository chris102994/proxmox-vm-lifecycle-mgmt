variant: fcos
version: 1.5.0
passwd:
  users:
    - name: root
      password_hash: ${default_password}
      ssh_authorized_keys:
        - ${ssh_pub_key}
    - name: ${default_user}
      password_hash: ${default_password}
      ssh_authorized_keys:
        - ${ssh_pub_key}
      groups:
        - wheel
        - sudo
storage:
  disks:
    # The link to the block device the OS was booted from
    - device: /dev/disk/by-id/coreos-boot-disk
      # We do NOT want to wipe the partition table since this is the primary device.
      wipe_table: false
      partitions:
        - number: 4
          label: root
          # Allocate at least 8GB to the rootfs
          size_mib: 8192
          resize: true
        - size_mib: 0
          # Assign a descriptive label to the partition. This is important
          # For referencing to it in a device-agnostic way in other parts of the configuration.
          label: var
  filesystems:
    - path: /var
      device: /dev/disk/by-partlabel/var
      format: xfs
      # Ask butane to generate a mount unit for us so that this FS gets mounted in real boot
      with_mount_unit: true
  files:
    - path: /etc/hostname
      contents:
        inline: "${hostname}"
      mode: 0644
    - path: /etc/NetworkManager/system-connections/${interface}.nmconnection
      mode: 0600
      contents:
        inline: |
          [connection]
          id=${interface}
          type=ethernet
          interface-name=${interface}
          [ipv4]
          address1=${ip_address}/${netmask},${gateway}
          dhcp-hostname=${hostname}
          dns=${dns}
          dns-search=
          may-fail=false
          method=manual
    - path: /etc/ssh/sshd_config.d/60-sshd-password-auth.conf
      mode: 0600
      contents:
        inline: |
           Match all
              # PermitRootLogin yes
              PasswordAuthentication yes
    - path: /etc/zincati/config.d/51-rollout-wariness.toml
      contents:
        inline: |
          [identity]
          rollout_wariness = 0.5
    - path: /etc/zincati/config.d/55-updates-strategy.toml
      contents:
        inline: |
          [updates]
          strategy = "periodic"
          [[updates.periodic.window]]
          days = [ "Sun", "Mon" ]
          start_time = "02:00"
          length_minutes = 60
systemd:
  units:
    - name: install-packages.service
      enabled: true
      contents: |
        [Unit]
        Description=Install packages
        After=network-online.target
        Wants=network-online.target
        ConditionPathExists=!/usr/bin/python3
        ConditionPathExists=!/usr/bin/qemu-ga
        
        [Service]
        Type=oneshot
        RemainAfterExit=true
        ExecStart=/usr/bin/rpm-ostree install -y --apply-live python3 qemu-guest-agent
        ExecStartPost=/usr/bin/systemctl reboot
        
        [Install]
        WantedBy=multi-user.target
    - name: qemu-guest-agent.service
      enabled: true
      contents: |
        [Unit]
        Description=QEMU Guest Agent
        BindTo=dev-virtio\x2dports-org.qemu.guest_agent.0.device
        After=dev-virtio\x2dports-org.qemu.guest_agent.0.device

        [Service]
        ExecStart=-/usr/bin/qemu-ga
        Restart=always
        RestartSec=0
        StartLimitInterval=0

        [Install]
        WantedBy=multi-user.target