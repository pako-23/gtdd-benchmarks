package tests;


import static org.junit.Assert.assertFalse;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import utils.DriverProvider;
import utils.Properties;
import utils.XpathGenerator;

public class DeleteDiscountCodeAmountTest {

	private WebDriver driver;
	private XpathGenerator xpgen;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
    	xpgen = new XpathGenerator();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

	@Test
	public void testExpressCartAddDiscountCodeAmount() throws Exception {
		driver.get(Properties.app_url+"/admin");
		driver.findElement(By.id("email")).sendKeys("owner@test.com");
		driver.findElement(By.id("password")).sendKeys("test");
		driver.findElement(By.id("loginForm")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[2]/li[4]/a")).click();
		String code = "discount000";
		WebElement codeElem = driver.findElement(By.xpath("//*[contains(text(), '"+code+"')]"));
		String codeXpath = xpgen.generateXpath(codeElem, "");
		codeXpath = codeXpath.replace("div[1]/span[1]", "div[4]/button");
		driver.findElement(By.xpath(codeXpath)).click();
		driver.switchTo().alert().accept();
		driver.switchTo().defaultContent();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[2]/li[4]/a")).click();
		assertFalse(driver.findElement(By.xpath("//*[@id=\"container\"]/div/main/div/ul")).getText().contains("Code:  "+code));
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
