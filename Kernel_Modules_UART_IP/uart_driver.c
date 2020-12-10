// QE IP Example
// QE Driver (qe_driver.c)
// Jason Losh

//-----------------------------------------------------------------------------
// Hardware Target
//-----------------------------------------------------------------------------

// Target Platform: DE1-SoC Board

// Hardware configuration:
// QE 0 and 1:
//   GPIO_1[29-28] are used for QE 0 inputs B and A
//   GPIO_1[31-30] are used for QE 1 inputs B and A
// HPS interface:
//   Mapped to offset of 0x1000 in light-weight MM interface aperature

// Load kernel module with insmod qe_driver.ko [param=___]

//-----------------------------------------------------------------------------

#include <linux/kernel.h>     // kstrtouint
#include <linux/module.h>     // MODULE_ macros
#include <linux/init.h>       // __init
#include <linux/kobject.h>    // kobject, kobject_atribute,
                              // kobject_create_and_add, kobject_put
#include <asm/io.h>           // iowrite, ioread, ioremap_nocache (platform specific)
#include "address_map.h"      // overall memory map
#include "uart_regs.h"          // register offsets in QE IP

//-----------------------------------------------------------------------------
// Kernel module information
//-----------------------------------------------------------------------------

MODULE_LICENSE("GPL");
MODULE_AUTHOR("KRISHNA PATEL");
MODULE_DESCRIPTION("UART IP Driver");

//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------

static unsigned int *uart_base = NULL;

//-----------------------------------------------------------------------------
// Subroutines
//-----------------------------------------------------------------------------

bool getUartTestCLKValue(uint8_t channel)
{
    return (ioread32(uart_base+OFS_UART_CONTROL));
}

uint32_t getSTATUSValue(uint8_t channel)
{
    return (ioread32(uart_base+OFS_UART_STATUS));
}

bool isEnableTX(uint8_t channel)
{
    return ((ioread32(uart_base+OFS_UART_CONTROL) >> 3) & 1);
}

void enableTX(uint8_t channel)
{
    unsigned int value = ioread32(uart_base+OFS_UART_CONTROL);
    iowrite32((value | 4) , uart_base+OFS_UART_CONTROL);
}

void disableTX(uint8_t channel)
{
    unsigned int value = ioread32(uart_base + OFS_UART_CONTROL);
    iowrite32(value & (~4) ,uart_base + OFS_UART_CONTROL);
}
void setBRDValue(uint32_t IBRD, uint32_t FBRD)
{
    iowrite32((IBRD << 5) | FBRD,uart_base+OFS_UART_BRD);
}
uint32_t getBRDValue(uint8_t channel)
{
    return (ioread32(uart_base + OFS_UART_BRD));
}

void txData( uint8_t value)
{
   iowrite32(value ,uart_base+OFS_UART_DATA);
}
uint8_t rxData(uint8_t channel)
{
    return (ioread32(uart_base+OFS_UART_DATA));;
}
//-----------------------------------------------------------------------------
// Kernel Objects
//-----------------------------------------------------------------------------

// Enable 0
static bool enable_TX = 0;
module_param(enable_TX, bool, S_IRUGO);
MODULE_PARM_DESC(enable_TX, "Enable Transmiter");

// echo
static ssize_t enable_TXStore(struct kobject *kobj, struct kobj_attribute *attr, const char *buffer, size_t count)
{
    if (strncmp(buffer, "true", count-1) == 0)
    {
        enableTX(0);
        enable_TX = true;
    }
    else
        if (strncmp(buffer, "false", count-1) == 0)
        {
            disableTX(0);
            enable_TX = false;
        }
    return count;
}
// cat
static ssize_t enable_TXShow(struct kobject *kobj, struct kobj_attribute *attr, char *buffer)
{
    enable_TX = isEnableTX(0);
    if (enable_TX)
        strcpy(buffer, "true\n");
    else
        strcpy(buffer, "false\n");
    return strlen(buffer);
}

static struct kobj_attribute enableTXAttr = __ATTR(enable_TX, 0664, enable_TXShow, enable_TXStore);

// This function is more proof of concept than functionality
// I wanted to test that kernel module is working
// properly calculate value 
// other wise kernel faults will occurr
// YOU HAVE BEEN WARNED :p
static unsigned int brd = 0;
module_param(brd, uint, S_IRUGO);
MODULE_PARM_DESC(brd, "BAUD RATE ");

static ssize_t brdStore(struct kobject *kobj, struct kobj_attribute *attr, const char *buffer, size_t count)
{
    int result = kstrtouint(buffer, 0, &brd);
    // did it successfully save data?
    if (result == 0)
        setBRDValue(brd, brd);
    return count;
}

static ssize_t brdShow(struct kobject *kobj, struct kobj_attribute *attr, char *buffer)
{
    brd = getBRDValue(0);
    return sprintf(buffer, "%d\n", brd);
}

static struct kobj_attribute brdAttr = __ATTR(brd, 0664, brdShow, brdStore);



static struct attribute *attrs0[] = {&enableTXAttr.attr, &brdAttr.attr, NULL};

static struct attribute_group group0 =
{
    .name = "uart",
    .attrs = attrs0
};


static struct kobject *kobj;

//-----------------------------------------------------------------------------
// Initialization and Exit
//-----------------------------------------------------------------------------

static int __init initialize_module(void)
{
    int result;

    printk(KERN_INFO "UART driver: starting\n");

    // Create qe directory under /sys/kernel
    kobj = kobject_create_and_add("uart", kernel_kobj);
    if (!kobj)
    {
        printk(KERN_ALERT "UART driver: failed to create and add kobj\n");
        return -ENOENT;
    }

    // Create qe0 and qe1 groups
    result = sysfs_create_group(kobj, &group0);
    if (result !=0)
        return result;
  

    // Physical to virtual memory map to access gpio registers
    uart_base = (unsigned int*)ioremap_nocache(LW_BRIDGE_BASE + UART_BASE_OFFSET,
                                          UART_SPAN_IN_BYTES);
    if (uart_base == NULL)
        return -ENODEV;

    printk(KERN_INFO "UART driver: initialized\n");

    return 0;
}


static void __exit exit_module(void)
{
    kobject_put(kobj);
    printk(KERN_INFO "UART driver: exit\n");
}

module_init(initialize_module);
module_exit(exit_module);

