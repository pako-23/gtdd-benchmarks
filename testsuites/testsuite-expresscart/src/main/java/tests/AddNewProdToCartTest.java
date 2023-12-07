package tests;


import static org.testng.AssertJUnit.assertEquals;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.CartSidebar;
import po.Home;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class AddNewProdToCartTest {

	private WebDriver driver;

    @Before
	public void setUp() {
    	driver = DriverProvider.getInstance().getDriver();
    	driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testExpressCartAddNewProdToCart() throws Exception {
		Home home = new Home(driver);
		home = home.goToProduct(1).addToCart().goHome();
		assertEquals(1, home.getCartCount());
		CartSidebar cart = home.openCart();
		Thread.sleep(500);
		assertEquals("NewProduct000", cart.getIthItem(1));
		home = cart.close();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
