package tests;


import static org.junit.Assert.assertTrue;
import static utils.Login.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import po.ManageFieldGroupsPage;

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.WebDriver;

import utils.DriverProvider;
import utils.Properties;

public class AddFieldGroupTest {

	private WebDriver driver;

    @Before
	public void setUp() {
        driver = DriverProvider.getInstance().getDriver();
        driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
        driver.get(Properties.app_url);
    }

	@Test
	public void testJoomlaAddFieldGroup() throws Exception {
		String group = "Test Group 000";
		ManageFieldGroupsPage groups = loginAsAdmin(driver)
			.siteAdmin()
			.setUsername("administrator")
			.setPassword("dodicicaratteri")
			.login()
			.sideContent()
			.fieldGroups()
			.createGroup()
			.setTitle(group)
			.saveAndClose();

		assertTrue(groups.isGroupPresent(group));
		groups.logout();
	}

	@After
	public void tearDown() throws Exception {
		driver.quit();
	}

}
