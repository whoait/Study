package org.o7planning.spring;
 
import org.o7planning.spring.bean.GreetingService;
import org.o7planning.spring.bean.MyComponent;
import org.o7planning.spring.config.AppConfiguration;
import org.o7planning.spring.lang.Language;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
 
public class MainProgram {
 
   public static void main(String[] args) {
  
      
       // Tạo ra một đối tượng ApplicationContext bằng cách đọc cấu hỉnh
       // trong class AppConfiguration
       ApplicationContext context = new AnnotationConfigApplicationContext(AppConfiguration.class);
 
       System.out.println("----------");
       Language language = (Language) context.getBean("language");
      
       System.out.println("Bean Language: "+ language);
       System.out.println("Call language.sayBye(): "+ language.getBye());
      
       System.out.println("----------");
      
       GreetingService service = (GreetingService) context.getBean("greetingService");
  
 
       service.sayGreeting();
  
       System.out.println("----------");
      
       MyComponent myComponent = (MyComponent) context.getBean("myComponent");
      
       myComponent.showAppInfo();
      
   }
  
}