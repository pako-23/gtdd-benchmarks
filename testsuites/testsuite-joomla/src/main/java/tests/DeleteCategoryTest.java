package tests;

import static org.junit.Assert.assertFalse;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import po.ManageCategoriesPage;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class DeleteCategoryTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaDeleteCategory() throws Exception {
		String category = "Test Category 000";
		ManageCategoriesPage categories = loginAsAdmin(driver)
				.siteAdmin()
				.setUsername("administrator")
				.setPassword("dodicicaratteri")
				.login()
				.categories()
				.selectThirdCategory()
				.deleteSelectedCategory();

		assertFalse(categories.containsCategoryAtThirdRow(category));
		categories.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
