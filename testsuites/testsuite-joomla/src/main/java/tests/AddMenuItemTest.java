package tests;

import static org.junit.Assert.assertTrue;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import po.MenuItemsPage;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class AddMenuItemTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaAddMenuItem() throws Exception {
		String name = "Test menu item";

		MenuItemsPage menuItems = loginAsAdmin(driver)
			.siteAdmin()
			.setUsername("administrator")
			.setPassword("dodicicaratteri")
			.login()
			.menus()
			.menuItems()
			.createMenuItem()
			.setTitle(name)
			.selectMenu("Main Menu")
			.selectArchivedArticleType()
			.save();

		assertTrue(menuItems.containsMenuItem(name));
		menuItems.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
