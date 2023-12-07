package tests;


import static org.testng.AssertJUnit.assertEquals;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class AddProductTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

	@Test
	public void testExpressCartAddProduct() throws Exception {
		driver.get(Properties.app_url + "/admin");
		driver.findElement(By.id("email")).sendKeys("owner@test.com");
		driver.findElement(By.id("password")).sendKeys("test");
		driver.findElement(By.id("loginForm")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[1]/li[3]/a[2]")).click();
		driver.findElement(By.id("productTitle")).sendKeys("NewProduct000");
		driver.findElement(By.id("productPrice")).sendKeys(Double.toString(15.95));
		driver.findElement(By.xpath("//*[@id=\"editor-wrapper\"]/div/div[3]/div[2]")).sendKeys("Description for product 000");
		driver.findElement(By.id("frm_edit_product_save")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[1]/li[3]/a[1]")).click();
		assertEquals(driver.findElement(By.xpath("//*[@id=\"container\"]/div/main/div[3]/ul/li[2]/div/a")).getText(), "NewProduct000");
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[3]/li/a")).click();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}
}
