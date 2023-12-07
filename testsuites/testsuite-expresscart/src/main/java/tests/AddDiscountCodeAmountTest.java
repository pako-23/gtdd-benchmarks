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

public class AddDiscountCodeAmountTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
    }

	@Test
	public void testExpressCartAddDiscountCodeAmount() throws Exception {
		String code = "discount000";
		driver.get(Properties.app_url + "/admin");
		driver.findElement(By.id("email")).sendKeys("owner@test.com");
		driver.findElement(By.id("password")).sendKeys("test");
		driver.findElement(By.id("loginForm")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[2]/li[4]/a")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/main/div/h2/div/a")).click();
		driver.findElement(By.id("discountCode")).sendKeys(code);
		driver.findElement(By.id("discountValue")).sendKeys("3");
		driver.findElement(By.id("discountStart")).sendKeys("12/02/2023 00:00");
		driver.findElement(By.xpath("/html/body/div[10]/div/div[3]/button[1]")).click();
		driver.findElement(By.id("discountEnd")).sendKeys("12/02/2024 00:00");
		driver.findElement(By.xpath("/html/body/div[11]/div/div[3]/button[1]")).click();
		driver.findElement(By.xpath("//*[@id=\"discountNewForm\"]/div[1]/div/div/button")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[2]/li[4]/a")).click();
		assertTrue(driver.findElement(By.xpath("//*[@id=\"container\"]/div/main/div/ul")).getText().contains("Code:  "+code));
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/nav/div/ul[3]/li/a")).click();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
