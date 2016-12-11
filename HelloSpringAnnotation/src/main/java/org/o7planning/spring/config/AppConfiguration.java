package org.o7planning.spring.config;

import org.o7planning.spring.lang.Language;
import org.o7planning.spring.lang.impl.Vietnamese;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan({"org.o7planning.spring.bean"})
public class AppConfiguration {
	
	@Bean(name = "language")
	public Language getLanguage(){
		
		return new Vietnamese();
	}
}
