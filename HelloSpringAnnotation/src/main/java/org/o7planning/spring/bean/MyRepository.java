package org.o7planning.spring.bean;
import java.util.Date;
import org.springframework.stereotype.Repository;

@Repository
public class MyRepository {
	
	public String getAppName(){
		return "Hello Spring app";
		
	}
	public Date getSystemDatetime(){
			
		return new Date();
	}
}
