//
//  URLHeader.h
//  LessonProject
//

#ifndef URLHeader_h
#define URLHeader_h

//http://192.168.0.200:8080/m
//beta.cyberfresh.cn
//admin.cyberfresh.cn

///App Store链接
#define appStoreURL @"https://itunes.apple.com/cn/app/%E8%B5%9B%E9%B2%9C/id1364356601?mt=8"

#define mTypeIOS @"IOS"

////URL:

#ifdef DEBUG
//do sth.
#define baseUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"server"]

#else
//do sth.
#define baseUrl @"http://admin.cyberfresh.cn"

#endif
//
////服务器
//#define baseUrl [[NSUserDefaults standardUserDefaults] objectForKey:@"server"]
//
////网页服务器
//#define webServerIP [[NSUserDefaults standardUserDefaults] objectForKey:@"webServer"]
//
//
//
//#define baseUrl @"http://beta.cyberfresh.cn"
//

///wangxiaoyang
#define WbaseUrl @"http://192.168.0.153/m"


////URL:本地
//#define baseUrl @"http://192.168.0.141"

////URL:本地
//#define baseUrl @"http://192.168.0.194"


///获取版本号
///http://192.168.0.200:8080/m/appversion/index.jhtml?appType=1






//#define zp @"http://beta.cyberfresh.cn"


//
/////本地测试
//
//#define loginKN @"http://192.168.0.120:7070"
//
//#define knL @"http://192.168.0.120/m"
//
//#define guiguan @"http://192.168.0.171:8080"
//
//#define baseUrl11 @"http://192.168.0.200:8080/m"
//
//
//










#endif /* URLHeader_h */
