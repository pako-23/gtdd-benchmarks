package tests;


import static org.testng.AssertJUnit.assertEquals;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.Home;
import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class DeletedDiscountCodeFailsAmountTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testExpressCartDeletedDiscountCodeFailsAmount() throws Exception {
		new Home(driver).account().setEmail("test@test.com").setPassword("test").login();
		driver.findElement(By.linkText("Home")).click();
		String code = "discount000";
		Home home = new Home(driver);
		home.goToProduct(1).addToCart();
		driver.findElement(By.xpath("//*[@id=\"navbarText\"]/ul/li/a")).click();
		Thread.sleep(500);
		driver.findElement(By.xpath("//*[@id=\"cart\"]/div[2]/div/a")).click();
		driver.findElement(By.id("checkoutInformation")).click();
		driver.findElement(By.xpath("//*[@id=\"container\"]/div/div/div/div[1]/a[2]")).click();
		driver.findElement(By.id("discountCode")).sendKeys(code);
		driver.findElement(By.id("addDiscountCode")).click();
		Thread.sleep(1000);
		assertEquals("Discount code is invalid or expired", driver.findElement(By.className("alert-danger")).getText());
		driver.findElement(By.xpath("//*[@id=\"navbarText\"]/ul/li/a")).click();
		Thread.sleep(500);
		driver.findElement(By.id("empty-cart")).click();
		driver.findElement(By.id("buttonConfirm")).click();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
