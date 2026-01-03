{ ... }:
{
  boot.kernelParams = [
    "8250.nr_uarts=1"
    # "vc_mem.mem_base=0x3ec00000"
    # "vc_mem.mem_size=0x20000000"
    "console=tty1"
    "snd_bcm2835.enable_hdmi=1"
    "snd_bcm2835.enable_headphones=1"
    # "psi=1"
    # "iommu=force"
    # "iomem=relaxed"
    # "swiotlb=131072"
  ];
}
