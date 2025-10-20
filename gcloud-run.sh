#!/bin/bash
# ==============================================
# Google Cloud VM Creator Script
# Usage: ./gcloud-run.sh [INSTANCE_NAME]
# Default instance name: n8n
# ==============================================

# --- Step 1: Read argument or set default
INSTANCE_NAME=${1:-n8n}
ZONE="us-central1-a"
MACHINE_TYPE="e2-medium"
DISK_SIZE="20"
IMAGE_FAMILY="ubuntu-2404-lts"
IMAGE_PROJECT="ubuntu-os-cloud"
STARTUP_SCRIPT="./startup.sh"
DISK_TYPE="ssd"

echo "🚀 Creating Compute Engine instance: $INSTANCE_NAME"

# --- Step 2: Create the instance with both HTTP & HTTPS tags
gcloud compute instances create "$INSTANCE_NAME" \
  --zone="$ZONE" \
  --machine-type="$MACHINE_TYPE" \
  --create-disk=auto-delete=yes,boot=yes,device-name="$INSTANCE_NAME",image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2404-noble-amd64-v20251002,mode=rw,size="$DISK_SIZE",type=pd-"$DISK_TYPE"
  --tags=http-server,https-server,lb-health-check \
  --metadata-from-file startup-script="$STARTUP_SCRIPT"
  --metadata enable-osconfig=TRUE

# --- Step 4: Ensure HTTPS firewall rule exists
echo "🔒 Ensuring HTTPS firewall rule is available..."
if ! gcloud compute firewall-rules list --filter="name=default-allow-https" --format="value(name)" | grep -q "default-allow-https"; then
  gcloud compute firewall-rules create default-allow-https \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=https-server
else
  echo "✅ Firewall rule 'default-allow-https' already exists."
fi

# --- Step 5: Ensure HTTP firewall rule exists
echo "🌐 Ensuring HTTP firewall rule is available..."
if ! gcloud compute firewall-rules list --filter="name=default-allow-http" --format="value(name)" | grep -q "default-allow-http"; then
  gcloud compute firewall-rules create default-allow-http \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server
else
  echo "✅ Firewall rule 'default-allow-http' already exists."
fi


# --- Step 4: Fetch startup-script serial output
echo "📜 Fetching startup-script logs (serial port output)..."
echo "-----------------------------------------------------------"
gcloud compute instances get-serial-port-output "$INSTANCE_NAME" --zone="$ZONE" --port=1 | grep startup-script || \
echo "⚠️  No startup-script log found yet. VM may still be booting."
echo "-----------------------------------------------------------"

echo "✅ Done!"

# --- Step 4: Show external IP address
echo "🌍 Fetching external IP address for $INSTANCE_NAME ..."
EXTERNAL_IP=$(gcloud compute instances describe "$INSTANCE_NAME" --zone="$ZONE" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

if [ -n "$EXTERNAL_IP" ]; then
  echo "✅ Instance '$INSTANCE_NAME' is ready!"
  echo "🌐 External IP: http://$EXTERNAL_IP"
  echo "🔒 HTTPS URL: https://$EXTERNAL_IP"
else
  echo "⚠️  Could not fetch external IP. Check if the instance has an external interface."
fi
