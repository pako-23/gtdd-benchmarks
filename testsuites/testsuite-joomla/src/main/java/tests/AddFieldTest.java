package tests;


import static org.junit.Assert.assertTrue;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.ManageFieldsPage;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import utils.DriverProvider;
import utils.Properties;

public class AddFieldTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaAddField() throws Exception {
		String field = "Test Field 000";
		ManageFieldsPage fields = loginAsAdmin(driver)
			.siteAdmin()
			.setUsername("administrator")
			.setPassword("dodicicaratteri")
			.login()
			.sideContent()
			.fields()
			.createField()
			.setTitle(field)
			.saveAndClose();

		assertTrue(fields.isFieldPresent(field));
		fields.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
