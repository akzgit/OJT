import tensorflow as tf

def get_gpu_info():
    # List available GPUs
    gpus = tf.config.list_physical_devices('GPU')
    
    if not gpus:
        print("No GPUs found.")
    else:
        for gpu in gpus:
            # Get GPU details
            details = tf.config.experimental.get_device_details(gpu)
            device_name = details.get('device_name', 'Unknown GPU')
            compute_capability = details.get('compute_capability', 'Unknown Compute Capability')
            print(f"GPU: {device_name}, Compute Capability: {compute_capability}")

get_gpu_info()
