

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Printer : NSObject
/**
 * 设置蓝牙传输类型  该指令用于告知打印机当前通信的接口类型，需要在每次连接成功后调用
 * 注意：该接口必须在每次建立连接后被正确调用一次，告知打印机当前使用的接口类型
 * @return 向打印机发送的数据
 */
-(NSData *) setBTType;
/**
 * 打印开始标志
 */
-(NSData *)  startPrintjob;

/**
 * 打印结束标志
 */
-(NSData *)  stopPrintjob;
/**
 * 打印机定位(自动方式)
 * @return 向打印机发送的数据
 */

-(NSData *) printerLocationAuto;
/**
 * 打印图片
 *
 * @param img 图片
 * @return 向打印机发送的数据
 */
-(NSData *) drawGraphic:(UIImage *)img;

/**
 * 调整打印纸位置
 *
 * @param mode    调整方式
 *                 0x00: 进纸 （单位：像素点）
 *                 0x01: 进纸 （单位：mm）
 *                 0x10: 退纸 （单位：像素点）
 *                 0x11: 退纸 （单位：mm）
 * @param distance 走纸距离
 * @return 向打印机发送的数据
 */

-(NSData *) adjustPosition:(int32_t) mode distance:(int32_t)distance;

/**
 * 自动调整打印纸位置
 *
 * @param mode    调整方式
 *                 0x50: 进纸
 *                 0x51: 退纸
 * @return 向打印机发送的数据
 */
-(NSData *) adjustPositionAuto:(int32_t) mode;


/**
 * 打印机定位（指定方式）
 *
 * @param mode 定位方式
 *              0x10: 连续纸（无定位）
 *              0x20: 定位到缝隙
 *              0x30: 定位到黑标
 * @param type 预留 设置为0
 * @return 向打印机发送的数据
 */
-(NSData *) printerLocation:(int32_t) mode type:(int32_t)type;

/**
 * 打印机状态查询（发送后，通过蓝牙读取到打印机状态）
 *
 * @param mode 0x00: 获取所有状态(1 字节)。第 0 位\;第 1 位 是否有纸，有纸 0，无纸 1;第 2 位是否欠 压，电压正常 0，欠压 1;第 3 位是否过 热，正常 0，过热 1;
 *              0x02: 是否有纸(1 字节) 0x00 正常,0x01 无纸
 *              0x03: 电池电压(1 字节) 0x00 正常,0x01 欠压
 *              0x04: 打印头是否过热(1 字节) 0x00 正常,0x01 过热
 * @return 向打印机发送的数据
 */
-(NSData *)checkPrinterStatus:(int32_t)mode;

/**
 * 设置打印机速度
 * @param mode 设置方式
 *              0x01: 设置打印速度，设置成功打印机返回”OK\r\n”，失败时打印机返回”ER\r\n”。
 *              0x02: 设置打印速度，无返回值
 * @param level 速度等级
 *              0x00: 低速
 *              0x01: 中速
 *              0x02: 高速
 * @return 向打印机发送的数据
 */
-(NSData *) setSpeed:(int32_t)mode level:(int32_t) level;

/**
 * 获取打印速度 （发送后，通过蓝牙读取到打印机状态）
 *
 * @return 向打印机发送的数据
 */
-(NSData *) getSpeed;

/**
 * 设置打印机浓度
 * @param mode 设置方式 1：设置打印机默认打印浓度 2：设置打印机临时打印浓度，仅对当前打印生效
 *              0x01: 设置默认打印浓度，成功返回”OK\r\n”，失败返回”ER\r\n”
 *              0x02: 设置打印浓度，无返回值
 * @param level 浓度等级 取1-16，由低到高16个等级的浓度，
 * @return 向打印机发送的数据
 */
-(NSData *) setDensity:(int32_t)mode level:(int32_t) level;
    
/**
 * 获取打印浓度（发送后，通过蓝牙读取到打印机状态，返回值为 1-16）
 * @return 向打印机发送的数据
 */
-(NSData *) getDensity;
/**
 * 设置纸张类型
 *
 * @param mode 设置方式
 *              0x01: 设置打印速度，设置成功打印机返回”OK\r\n”，失败时打印机返回”ER\r\n”。
 *              0x02: 设置打印速度，无返回值
 * @param type 纸张类型
 *             0x10: 连续纸
 *             0x20: 缝隙纸
 *             0x30: 黑标纸
 * @return 向打印机发送的数据
 */
-(NSData *) setPaperType:(int32_t)mode type:(int32_t) type;
/**
 * 获取纸张类型（发送后，通过蓝牙读取到打印机纸张类型 0x10: 连续纸 0x20: 缝隙纸 0x30: 黑标纸
 *
 * @return 向打印机发送的数据
 */
-(NSData *) getPaperType;
/**
 * 获取打印机信息（发送后需要通过蓝牙读取结果）
 *
 * @param mode 0x00：读打印机型号
 *             0x04：读固件版本
 *             0x06：读序列号 SN
 *             0x08：读生产日期
 * @return 向打印机发送的数据
 */
-(NSData *)checkPrinterInf:(int32_t)mode;
/**
 * 获取蓝牙信息
 * @param mode
 *            0x04:读蓝牙2.0 mac
 *            0x06:读蓝牙4.0 mac
 *            0x08:读版本
 * @return 向打印机发送的数据
 */
-(NSData *)checkBTInf:(int32_t)mode;

@end
