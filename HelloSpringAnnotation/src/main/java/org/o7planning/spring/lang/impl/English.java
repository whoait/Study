package org.o7planning.spring.lang.impl;
import org.o7planning.spring.lang.Language;

public class English implements Language{
	@Override
	public String getGreeting(){
		return "Hello";
	}
	@Override
	public String getBye(){
		return "Byebye";	
	}
}