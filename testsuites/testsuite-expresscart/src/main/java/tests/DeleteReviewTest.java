package tests;


import static org.junit.Assert.assertFalse;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class DeleteReviewTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

	@Test
	public void testExpressCartDeleteReview() throws Exception {
		driver.get(Properties.app_url+"/admin");
		driver.findElement(By.id("email")).sendKeys("owner@test.com");
		driver.findElement(By.id("password")).sendKeys("test");
		driver.findElement(By.id("loginForm")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[1]/li[8]/a")).click();
		driver.findElement(By.xpath("/html/body/div[2]/div/main/div[3]/ul/li[2]/div/div[4]/a")).click();
		driver.switchTo().alert().accept();
		driver.switchTo().defaultContent();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[1]/li[8]/a")).click();
		assertFalse(driver.findElement(By.xpath("/html/body/div[2]/div/main/div[3]/ul/li[2]/div/div[1]/div")).getText().contains("Review000"));
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[3]/li/a")).click();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
