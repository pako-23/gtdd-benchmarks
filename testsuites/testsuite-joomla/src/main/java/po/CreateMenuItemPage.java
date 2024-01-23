package po;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;
import org.openqa.selenium.support.ui.Select;

public class CreateMenuItemPage extends PageObject {
	
	@FindBy(id = "jform_title")
	protected WebElement title;
	
	@FindBy(xpath = "//*[@id=\"details\"]/div/div[1]/div[1]/div[2]/span/button")
	protected WebElement menuItemType;
	
	@FindBy(className = "button-save")
	protected WebElement saveBtn;
	
	public CreateMenuItemPage(WebDriver driver) {
		super(driver);
		// TODO Auto-generated constructor stub
	}
	
	public CreateMenuItemPage setTitle(String ttl) {
		title.sendKeys(ttl);
		return this;
	}
	
	public CreateMenuItemPage selectMenu(String menu) {
		new Select(driver.findElement(By.id("jform_menutype"))).selectByVisibleText(menu);
		return this;
	}
	
	public CreateMenuItemPage selectArchivedArticleType() {
		menuItemType.click();
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		driver.switchTo().frame(driver.findElement(By.className("iframe")));
		driver.findElement(By.xpath("//*[@id=\"collapse0-heading\"]/button")).click();
		//driver.findElement(By.partialLinkText("Archived Articles")).click();
		driver.findElement(By.xpath("//*[@id=\"collapse0\"]/div/div/a[1]/div")).click();
		driver.switchTo().defaultContent();
		return this;
	}
	
	public MenuItemsPage save() {
		saveBtn.click();
		return new MenuItemsPage(driver);
	}

}
