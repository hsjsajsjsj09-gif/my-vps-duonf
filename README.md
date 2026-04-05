# Windows VPS RDP + GPU để chơi Minecraft (Template GitHub)

Bộ mã này giúp bạn triển khai **Windows VPS có GPU**, bật **RDP** để remote desktop và cài nhanh môi trường chơi Minecraft.

> ⚠️ Lưu ý: chơi game trên cloud có thể tốn phí cao (GPU tính tiền theo giờ). Hãy tắt VM khi không dùng.

## Tính năng
- Triển khai hạ tầng bằng **Terraform** (Azure).
- Tạo VM Windows với GPU (ví dụ `Standard_NV6ads_A10_v5`).
- Mở cổng RDP `3389` theo IP cho phép.
- Script PowerShell cài:
  - Java 21
  - Prism Launcher (launcher Minecraft mã nguồn mở)
  - VC++ Runtime
  - Tối ưu cấu hình Windows cơ bản cho stream/chơi game

## Cấu trúc repo
- `terraform/`: mã IaC để tạo hạ tầng.
- `scripts/setup-minecraft-vps.ps1`: script cài môi trường chơi Minecraft.
- `scripts/start-minecraft-server.ps1`: script tùy chọn để chạy Minecraft server trên chính VPS.

## 1) Chuẩn bị
1. Tài khoản Azure có quota máy GPU.
2. Cài sẵn:
   - [Terraform](https://developer.hashicorp.com/terraform/downloads)
   - [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
3. Đăng nhập Azure CLI:

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

## 2) Cấu hình Terraform
Vào thư mục `terraform` và tạo file biến:

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Sửa `terraform.tfvars`:
- `admin_username`, `admin_password`: tài khoản đăng nhập RDP.
- `allowed_rdp_cidr`: IP của bạn, ví dụ `203.0.113.10/32`.
- `location`: vùng có GPU quota.
- `vm_size`: mặc định `Standard_NV6ads_A10_v5`.

## 3) Triển khai VPS
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Sau khi xong, Terraform sẽ in ra:
- `public_ip`
- `rdp_command`

Kết nối RDP (Windows):
```powershell
mstsc /v:<public_ip>
```

## 4) Cài Minecraft trên VPS
Sau khi đăng nhập RDP, mở **PowerShell as Administrator** và chạy:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
cd C:\
# Tải script từ repo của bạn, hoặc copy trực tiếp file scripts/setup-minecraft-vps.ps1 vào máy
.\setup-minecraft-vps.ps1
```

Script sẽ cài Java + Prism Launcher. Sau đó:
1. Mở Prism Launcher.
2. Đăng nhập tài khoản Microsoft/Minecraft.
3. Tạo instance (vanilla/Fabric/Forge) và chọn phiên bản.
4. Trong Settings -> Java, chọn RAM phù hợp (4–8 GB cho modpack nhẹ/trung bình).

## 5) (Tùy chọn) chạy server Minecraft trên chính VPS
```powershell
cd C:\
.\start-minecraft-server.ps1 -McVersion "1.20.6" -ServerDir "C:\mc-server" -Memory "6G"
```

Server sẽ mở cổng `25565` nội bộ. Nếu muốn public server, cần mở NSG inbound `25565` và cấu hình firewall an toàn.

## 6) Tắt tài nguyên để tránh tốn phí
Khi không chơi nữa:
```bash
terraform destroy -auto-approve
```

## Lưu ý hiệu năng
- Độ trễ tốt khi chọn region gần bạn.
- Dùng mạng dây và stream ở 1080p/60fps để giảm input lag.
- Nếu VM chưa có driver GPU đầy đủ, cài Azure GPU driver extension theo tài liệu chính thức của Azure.

## Bảo mật
- Không mở `3389` cho toàn internet (`0.0.0.0/0`).
- Dùng mật khẩu mạnh hoặc Azure Bastion.
- Có thể đổi cổng RDP custom + giới hạn IP.
