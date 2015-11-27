//
//  NFXSettingsController.swift
//  netfox
//
//  Copyright © 2015 kasketis. All rights reserved.
//

import Foundation
import UIKit

class NFXSettingsController: NFXGenericController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate
{
    // MARK: Properties

    var nfxURL = "https://github.com/kasketis/netfox"
    
    var tableView: UITableView = UITableView()
    
    var tableData = [HTTPModelShortType]()
    var filters = [Bool]()

    // MARK: View Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Settings"
                
        self.tableData = HTTPModelShortType.allValues
        self.filters =  NFX.sharedInstance().getCachedFilters()
        
        self.edgesForExtendedLayout = .None
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 60)
        self.tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.tableView.translatesAutoresizingMaskIntoConstraints = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.alwaysBounceVertical = false
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView?.hidden = true
        self.view.addSubview(self.tableView)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        
        var nfxVersionLabel: UILabel
        nfxVersionLabel = UILabel(frame: CGRectMake(10, CGRectGetHeight(self.view.frame) - 60, CGRectGetWidth(self.view.frame) - 2*10, 30))
        nfxVersionLabel.autoresizingMask = [.FlexibleTopMargin]
        nfxVersionLabel.font = UIFont.NFXFont(14)
        nfxVersionLabel.textColor = UIColor.NFXOrangeColor()
        nfxVersionLabel.textAlignment = .Center
        nfxVersionLabel.text = "netfox - \(nfxVersion)"
        self.view.addSubview(nfxVersionLabel)
        
        var nfxURLButton: UIButton
        nfxURLButton = UIButton(frame: CGRectMake(10, CGRectGetHeight(self.view.frame) - 40, CGRectGetWidth(self.view.frame) - 2*10, 30))
        nfxURLButton.autoresizingMask = [.FlexibleTopMargin]
        nfxURLButton.titleLabel?.font = UIFont.NFXFont(12)
        nfxURLButton.setTitleColor(UIColor.NFXGray44Color(), forState: .Normal)
        nfxURLButton.titleLabel?.textAlignment = .Center
        nfxURLButton.setTitle(nfxURL, forState: .Normal)
        nfxURLButton.addTarget(self, action: Selector("nfxURLButtonPressed"), forControlEvents: .TouchUpInside)
        self.view.addSubview(nfxURLButton)
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        NFX.sharedInstance().cacheFilters(self.filters)
    }
    
    func nfxURLButtonPressed()
    {
        UIApplication.sharedApplication().openURL(NSURL(string: nfxURL)!)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
        case 0: return 1
        case 1: return self.tableData.count
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
        cell.textLabel?.font = UIFont.NFXFont(14)
        cell.tintColor = UIColor.NFXOrangeColor()

        switch indexPath.section
        {
        case 0:
            cell.textLabel?.text = "Logging"
            let nfxEnabledSwitch: UISwitch
            nfxEnabledSwitch = UISwitch()
            nfxEnabledSwitch.setOn(NFX.sharedInstance().isEnabled(), animated: false)
            nfxEnabledSwitch.addTarget(self, action: Selector("nfxEnabledSwitchValueChanged:"), forControlEvents: .ValueChanged)
            cell.accessoryView = nfxEnabledSwitch
            return cell
            
        case 1:
            let shortType = tableData[indexPath.row]
            cell.textLabel?.text = shortType.rawValue
            configureCell(cell, indexPath: indexPath)
            return cell

        case 2:
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.text = "Clear data"
            cell.textLabel?.textColor = UIColor.NFXRedColor()
            return cell

            
        default: return UITableViewCell()

        }
        
    }
    
    func reloadTableData()
    {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
            self.tableView.setNeedsDisplay()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.NFXGray95Color()
        
        switch section {
        case 1:
            
            var filtersInfoLabel: UILabel
            filtersInfoLabel = UILabel(frame: headerView.bounds)
            filtersInfoLabel.backgroundColor = UIColor.clearColor()
            filtersInfoLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            filtersInfoLabel.font = UIFont.NFXFont(13)
            filtersInfoLabel.textColor = UIColor.NFXGray44Color()
            filtersInfoLabel.textAlignment = .Center
            filtersInfoLabel.text = "\nSelect the types of responses that you want to see"
            filtersInfoLabel.numberOfLines = 2
            headerView.addSubview(filtersInfoLabel)
            
            
        default: break
        }
        
        return headerView

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.section
        {
        case 1:
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            self.filters[indexPath.row] = !self.filters[indexPath.row]
            configureCell(cell, indexPath: indexPath)
            break
            
        case 2:
            clearDataButtonPressed()
            break
            
        default: break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)


    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.section {
        case 0: return 44
        case 1: return 33
        case 2: return 44
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        switch section {
        case 0: return 40
        case 1: return 60
        case 2: return 50
        default: return 0
        }
    }
    
    func configureCell(cell: UITableViewCell?, indexPath: NSIndexPath)
    {
        if (cell != nil) {
            if self.filters[indexPath.row] {
                cell!.accessoryType = .Checkmark
            } else {
                cell!.accessoryType = .None
            }
        }

    }
    
    func nfxEnabledSwitchValueChanged(sender: UISwitch)
    {
        if sender.on {
            NFX.sharedInstance().enable()
        } else {
            NFX.sharedInstance().disable()
        }
    }
    
    func clearDataButtonPressed()
    {
        var actionSheet: UIActionSheet
        actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.title = "Clear data?"
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.addButtonWithTitle("Yes")
        actionSheet.addButtonWithTitle("No")
        actionSheet.cancelButtonIndex = 0
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1 {
           NFX.sharedInstance().clearOldData()
        }
    }
    
    
}