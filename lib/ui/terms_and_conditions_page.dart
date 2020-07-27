import 'package:flutter/material.dart';
import 'package:moonblink/global/router_manager.dart';

const TextStyle titleTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
const TextStyle subtitleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
const TextStyle contentTextStyle = TextStyle(fontWeight: FontWeight.w300);

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
            child: Column(
        children: <Widget>[Text('MoonBlink\'s'), Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text('Terms and Conditions', style: TextStyle(fontSize: 16)),
        )],
      ),
          )),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('MoonBlink > Privacy Policy', style: titleTextStyle),
                      Divider(thickness: 2.0),
                      Text('Privacy Policy', style: subtitleTextStyle),
                      Text('\n[Developer/Company name] built the MoonBlink app as [open source/free/freemium/ad-supported/commercial] app. This SERVICE is provided by [Developer/Company name] [at no cost] and is intended for use as is. \n\nThis page is used to inform visitors regarding [my/our] policies with the collection, use, and disclosure of Personal Information if anyone decided to use [my/our] Service.\n\nIf you choose to use [my/our] Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that [I/We] collect is used for providing and improving the Service. [I/We] will not use or share your information with anyone except as described in this Privacy Policy.\n\nThe terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which is accessible at MoonBlink unless otherwise defined in this Privacy Policy.\n', style: contentTextStyle),
                      Text('Information Collection and Use', style: subtitleTextStyle),
                      Text('\nFor a better experience, while using our Service, [I/We] may require you to provide us with certain personally identifiable information[add whatever else you collect here, e.g. users name, address, location, pictures] The information that [I/We] request will be [retained on your device and is not collected by [me/us] in any way]/[retained by us and used as described in this privacy policy].\n\nThe app does use third party services that may collect information used to identify you.\n\nLink to privacy policy of third party service providers used by the app\n\n  - Google Play Services\n', style: contentTextStyle),
                      Text('Log Data', style: subtitleTextStyle),
                      Text('\n[I/We] want to inform you that whenever you use [my/our] Service, in a case of an error in the app [I/We] collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing [my/our] Service, the time and date of your use of the Service, and other statistics.\n', style: contentTextStyle),
                      Text('Cookies', style: subtitleTextStyle),
                      Text('\nCookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device\'s internal memory.\n\nThis Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.\n', style: contentTextStyle),
                      Text('Service Providers', style: subtitleTextStyle),
                      Text('\n[I/We] may employ third-party companies and individuals due to the following reasons:\n\n  - To facilitate our Service;\n  - To provide the Service on our behalf;\n  - To perform Service-related services; or\n  - To assist us in analyzing how our Service is used.\n\n[I/We] want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.\n', style: contentTextStyle),
                      Text('Security', style: subtitleTextStyle),
                      Text('\n[I/We] value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and [I/We] cannot guarantee its absolute security.\n', style: contentTextStyle),
                      Text('Links to Other Sites', style: subtitleTextStyle),
                      Text('\nThis Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by [me/us]. Therefore, [I/We] strongly advise you to review the Privacy Policy of these websites. [I/We] have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.\n', style: contentTextStyle),
                      Text('Children’s Privacy', style: subtitleTextStyle),
                      Text('\nThese Services do not address anyone under the age of 13. [I/We] do not knowingly collect personally identifiable information from children under 13. In the case [I/We] discover that a child under 13 has provided [me/us] with personal information, [I/We] immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact [me/us] so that [I/We] will be able to do necessary actions.\n', style: contentTextStyle),
                      Text('Changes to This Privacy Policy', style: subtitleTextStyle),
                      Text('\n[I/We] may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. [I/We] will notify you of any changes by posting the new Privacy Policy on this page.\n\nThis policy is effective as of 2020-07-08\n', style: contentTextStyle),
                      Text('Contact Us', style: subtitleTextStyle),
                      Text('\nIf you have any questions or suggestions about [my/our] Privacy Policy, do not hesitate to contact [me/us] at moonblink.com2017@gmail.com.\n', style: contentTextStyle),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                width: double.infinity,
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Text('Accept'),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(context, RouteName.main, (route) => false),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
