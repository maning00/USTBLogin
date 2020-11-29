//
//  main.cpp
//  USTBLogin
//
//  Created by Ning Ma on 11/27/20.
//

#include <iostream>
#include <string>
#include <curl/curl.h>
#include <unistd.h>

using namespace std;
struct memory {
   char *response;
   size_t size;
 };
 
 static size_t call_back(void *data, size_t size, size_t nmemb, struct memory *mem) //回调函数，用于接收响应
 {
     size_t realsize = mem->size + size * nmemb;
     mem->response = (char*)realloc(mem->response, realsize+1);
     if(mem->response==nullptr){
         fprintf(stderr, "realloc() failed\n");
         exit(EXIT_FAILURE);
     }
     memcpy(mem->response+mem->size,data,size*nmemb);
     mem->response[realsize] = '\0';
     mem->size = realsize;
     return size*nmemb;
 }
void init_memory(struct memory *s){
    s->size = 0;
    s->response = (char*)malloc(s->size+1);
    if (s->response == NULL) {
        fprintf(stderr, "malloc() failed\n");
        exit(EXIT_FAILURE);
    }
    s->response[0] = '\0';
}

char* get_ip(){   //获取v6地址
    auto curl = curl_easy_init();
    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "http://cippv6.ustb.edu.cn/get_ip.php");
        curl_easy_setopt(curl, CURLOPT_HTTP_VERSION,CURL_HTTP_VERSION_1_1);
        curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);
        curl_easy_setopt(curl, CURLOPT_FORBID_REUSE, 1L);
        curl_easy_setopt(curl, CURLOPT_USERAGENT,"Mozilla/5.0");
        memory response;
        init_memory(&response);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION,call_back);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
        CURLcode code = curl_easy_perform(curl);
        if(code !=CURLE_OK){ //判断是否能正确获得ipv6地址
            std::cerr<<"FAILED to get IPv6 Address: "<<curl_easy_strerror(code);
            return nullptr;
        }
        curl_easy_cleanup(curl);
        char *ipv6 = new char[39];
        strncpy(ipv6, response.response+13, strlen(response.response)-19);
        //std::cout<<"response: "<<response.size <<std::endl;
        
        curl = nullptr;
        return ipv6;
    }
    return nullptr;
}

void Login(const char* name,const char* password){
    CURL *curl;
    CURLcode code;
    curl = curl_easy_init();
    char body[100];
    char cookie[50];
    strcpy(cookie,"myusername="); //根据登录格式获取cookie和body
    strcat(cookie,name);
    strcat(cookie,"; username=");
    strcat(cookie,name);
    strcpy(body, "DDDDD=");
    strcat(body,name);
    strcat(body,"&upass=");
    strcat(body, password);
    strcat(body,"&v6ip=");
    char *ip = get_ip();
    if(ip) strcat(body, ip);
    strcat(body,"&0MKKey=123456789");
    if(curl){
        curl_easy_setopt(curl, CURLOPT_URL,"http://login.ustb.edu.cn/");
        curl_easy_setopt(curl, CURLOPT_HTTP_VERSION,CURL_HTTP_VERSION_1_1);
        curl_easy_setopt(curl, CURLOPT_COOKIE,cookie);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)strlen(body));
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, body);
        std::string response_string;
        std::string header_string;
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION,call_back);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response_string);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, &header_string);
        
        code = curl_easy_perform(curl);
        if(code !=CURLE_OK)
            std::cerr<<"curl_easy_perform FAILED: "<<curl_easy_strerror(code);
    }
    curl_easy_cleanup(curl);
}

void Logout(){
    auto curl = curl_easy_init();
    if(curl) {
        curl_easy_setopt(curl, CURLOPT_URL, "http://login.ustb.edu.cn/F.htm");
        curl_easy_setopt(curl, CURLOPT_HTTP_VERSION,CURL_HTTP_VERSION_1_1);
        curl_easy_setopt(curl, CURLOPT_HTTPGET, 1L);
        curl_easy_setopt(curl, CURLOPT_FORBID_REUSE, 1L);
        curl_easy_setopt(curl, CURLOPT_USERAGENT,"Mozilla/5.0");
        
        std::string response_string;
        std::string header_string;
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION,call_back);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response_string);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, &header_string);
        curl_easy_perform(curl);
        curl_easy_cleanup(curl);
        curl = nullptr;
    }
}

void usage(void)
{
    cerr<<"usage: ustbLogin [-option]"<<endl;
    cerr<<"   -l [username] [password]: Login"<<endl;
    cerr<<"   -o: Log out"<<endl;
    
    
    exit(EXIT_FAILURE);
}


int main(int argc,char *argv[])
{
    int c = 0; //用于接收选项
    while(EOF != (c = getopt(argc,argv,"lo")))
    {
        switch(c)
        {
            case 'l':
                if(argc!=4) usage();
                printf("Log in..\n");
                Login(argv[2], argv[3]);
                break;
            case 'o':
                printf("Log out..\n");
                break;
            default:
                usage();
        }
    }
    return 0;
}
