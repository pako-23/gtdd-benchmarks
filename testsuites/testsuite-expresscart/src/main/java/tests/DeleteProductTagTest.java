package tests;


import static org.junit.Assert.assertTrue;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class DeleteProductTagTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url+"/admin");
    }

	@Test
	public void testExpressCartDeleteProductTag() throws Exception {
		driver.findElement(By.id("email")).sendKeys("owner@test.com");
		driver.findElement(By.id("password")).sendKeys("test");
		driver.findElement(By.id("loginForm")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[1]/li[3]/a[1]")).click();
		driver.findElement(By.linkText("NewProduct000")).click();
		driver.findElement(By.xpath("//*[@id=\"productEditForm\"]/div/div[9]/div/div/div/a")).click();
		assertTrue(driver.findElement(By.id("productTags-tokenfield")).getAttribute("value").equals(""));
		driver.findElement(By.id("productUpdate")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[1]/li[3]/a[1]")).click();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
