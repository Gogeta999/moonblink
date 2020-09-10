import 'package:flutter/material.dart';
import 'package:moonblink/base_widget/appbar/appbarlogo.dart';
import 'package:moonblink/base_widget/container/titleContainer.dart';
import 'package:moonblink/generated/l10n.dart';
import 'package:moonblink/global/router_manager.dart';
import 'package:moonblink/global/storage_manager.dart';
import 'package:moonblink/utils/platform_utils.dart';
import 'package:moonblink/view_model/user_model.dart';
import 'package:oktoast/oktoast.dart';

const TextStyle titleTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
const TextStyle subtitleTextStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
const TextStyle contentTextStyle = TextStyle(fontWeight: FontWeight.w300);

class TermsAndConditions extends StatelessWidget {
  final bool showAccept;

  const TermsAndConditions({Key key, this.showAccept = true}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var hasUser = StorageManager.localStorage.getItem(mUser);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          AppbarLogo(),
        ],
      ),
      body: SafeArea(
        child: Container(
          // margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: ListView(
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    color: Colors.black,
                    height: 200,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 150),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(50.0)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                    child: TitleContainer(
                      height: 100,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Center(
                          child: Text(
                        "Terms and Conditions",
                        style: TextStyle(fontSize: 30),
                      )),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 180),
                    child: Center(
                      child: Text('MoonBlink > Terms and Conditions',
                          textAlign: TextAlign.justify, style: titleTextStyle),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Divider(thickness: 2.0),
                        Text('Account registration',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nBefore using this service, the user needs to register a "Moon Go" account. You can log in directly with the google and facebook account to bind and register. Moonblink Group can change the way of account registration and binding according to user needs or product needs without prior notice to users.\n\n"Moon Go" is a mobile social product based on game products. The user needs to bind the role information of the corresponding game product when registering. Therefore, the completion of the user registration means that the user agrees to Moonblink Group to extract, disclose and use the user\'s game product role information. If the user needs to change the bound role information, he can modify or re-bind it in the APP.\n\nIn view of the binding registration method of the "moongo" account, you agree that Moonblink Group will use the mobile phone number you provided and/or automatically extract your mobile phone number and automatically extract your mobile device identification code and other information when registering Used for registration.\n\nWhen users register and use this service, Moonblink Group needs to collect personal information that can identify the user so that Moonblink Group can contact users when necessary, or provide users with a better experience. The information collected by Moonblink Group includes but is not limited to the user’s name, gender, age, date of birth, ID number, address, school information, company information, industry, hobbies, and personal description; Moonblink Group agrees to the information The use will be subject to the restrictions of the third user\'s personal privacy information protection.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Service content',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nThe specific content of this service is provided by Moonblink Group according to the actual situation, including but not limited to authorized users to conduct instant messaging through their accounts, check platform user game role information, add friends, join groups, follow others, and post messages. Moonblink Group may change the services it provides, and the content of services provided by Moonblink Group may change at any time, and users will receive notice from Moonblink Group about service changes.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            'Protection of users\' personal privacy information',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            (('\nIn the process of registering an account or using this service, the user may need to fill in or submit some necessary information, such as the identity information required by laws, regulations, and regulatory documents (hereinafter referred to as "laws and regulations"). If the information submitted by the user is incomplete or does not meet the requirements of laws and regulations, the user may not be able to use the service or be restricted in the process of using the service.\n\nPersonal privacy information refers to information related to the user\'s personal identity or personal privacy, such as the user\'s real name, ID number, mobile phone number, mobile device identification code, IP address, and user chat history. Non-personal private information refers to the basic record information of the user\'s operating status and usage habits of this service, which is clearly and objectively reflected on the Moonblink Group server, other general information outside the scope of personal private information, and the above-mentioned private information that the user agrees to disclose.\n\nRespecting the privacy of users’ personal privacy information is Moonblink Group’s consistent system.Moonblink Group will take technical measures and other necessary measures to ensure the security of users’ personal privacy information and prevent the leakage of user’s personal privacy information collected in this service. Damage or loss, in the event of the foregoing circumstances or Moonblink Group discovers that the foregoing circumstances may occur, remedial measures will be taken in a timely manner.\n\nMoonblink Group will not disclose or disclose users\' personal privacy information to any third party without the user\'s consent. Except in the following specific situations:\n\n - Moonblink Group provides users\' personal privacy information in accordance with laws and regulations or instructions from competent authorities.\n - Any leakage of personal information caused by the user telling others of their user password or sharing the registered account and password with others, or other personal privacy information leakage not caused by Moonblink Group.\n - '
                                'Users disclose their personal privacy information to third parties by themselves.\n - The user and Moonblink Group and the cooperative unit have reached an agreement on the use and disclosure of the user\'s personal privacy information, and Moonblink Group therefore discloses the user\'s personal privacy information to the cooperative unit.\n - Any leakage of personal privacy information of users due to hacker attacks, computer virus intrusion and other force majeure events.\nThe user agrees that Moonblink Group may use the user\'s personal privacy information in the following matters:\n - Moonblink Group sends important notices to users in a timely manner, such as software updates and changes to the terms of this agreement.\n - Moonblink Group conducts internal audits, data analysis and research to improve Moonblink Group’s products, services and communication with users.\n - According to this agreement, Moonblink Group manages, reviews user information and takes handling measures.\n - Other matters stipulated by applicable laws and regulations.\nIn addition to the above matters, Moonblink Group will not use the user\'s personal privacy information for any other purposes without the user\'s prior consent.\nThe user confirms that his game product information is non-personal private information, and the user\'s successful registration of the "moongo" account is deemed to be a confirmation that Moonblink Group is authorized to extract, disclose and use the user\'s game product information. The user\'s game product information will be one of the user\'s public information, which will be disclosed by Moonblink Group to other users. If users need to change and disclose their game product information to other users, they can set or change them at any time.\nIn order to improve Moonblink Group\'s technology and services and provide users with a better service experience, Moonblink Group may collect and use or provide users\' non-personal privacy information to third parties.\n')),
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Content Specifications',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nThe content mentioned in this article refers to any content created, uploaded, copied, published, or disseminated during the user\'s use of this service, including but not limited to account avatars, names, user descriptions and other registration information and authentication materials, or text, voice , Pictures, videos, graphics, etc. to send, reply or automatically reply to messages and related linked pages, as well as other content generated by using the account or the service.\n\nUsers are not allowed to use the "Moongo" account or this service to produce, upload, copy, publish, or disseminate the following contents prohibited by laws, regulations and policies:\n - Oppose the basic principles established by the Constitution.\n - Endangering national security, leaking state secrets, subverting state power, and undermining national unity.\n - Damage to national honor and interests.\n - Inciting ethnic hatred, ethnic discrimination, and undermining ethnic unity.\n - Undermining the state\'s religious policies and promoting cults and feudal superstition.\n - Spreading rumors, disrupting social order, and undermining social stability.\n - Spreading obscenity, pornography, gambling, violence, murder, terror or instigating crime.\n - Insulting or slandering others, infringing on the lawful rights and interests of others.\n - Failure to comply with the "seven bottom lines" requirements of laws and regulations, the bottom line of the socialist system, the bottom line of national interests, the bottom line ofcitizens\' legitimate rights and interests, the bottom line of social public order, the bottom line of morality and the bottom line of information authenticity.\n - Information containing other content prohibited by laws and administrative regulations.\n\n Users are not allowed to use the "Moongo" account or this service to produce, upload, copy, publish, and disseminate the following content that interferes with the normal operation of "Moongo" and infringes the legal rights of other users or third parties:\n - Contains any sexual or sexual suggestion.\n - Contains abusive, intimidating, or threatening content.\n - Contains harassment, spam, malicious information, or deceptive information.\n - Involving the privacy, personal information or data of others.\n - Infringement of legal rights such as reputation rights, portrait rights, intellectual property rights, and trade secrets of others.\n - Contains other information that interferes with the normal operation of this service and infringes the legitimate rights and interests of other users or third parties.',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Use rules',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nAny content transmitted or published by users in or through this service does not reflect or represent, nor should it be deemed to reflect or represent Moonblink Group’s views, positions or policies. Moonblink Group does not bear any responsibility for this. responsibility.\n\nUsers are not allowed to use the "Moongo" account or this service to do the following:\n - Submitting or publishing false information, or embezzling other people\'s avatars or materials, impersonating or using other people\'s names.\n - Forcing or inducing other users to follow, click on linked pages or share information.\n - Fictional facts and concealing the truth to mislead or deceive others.\n - Using technical means to establish false accounts in batches.\n - Engaging in any illegal or criminal activity using the "Moongo" account or this service.\n - Making and publishing methods and tools related to the above behaviors, or operating or disseminating such methods and tools, regardless of whether these behaviors are for commercial purposes.\n - Other acts that violate laws and regulations, infringe on the legitimate rights and interests of other users, interfere with the normal operation of "Moongo", or Moonblink Group has not expressly authorized behavior.\n - Distributing advertisements by using functions such as communication, community posting, and chat room speech in the Moongo App, which damages the interests of the "Moongo" platform and users.\n - Use the communication, community, news, chat room speech and other functions in the Moongo App to distribute or carry out the transaction information or transaction behavior of virtual items (including but not limited to chat room gifts) or go coin in the Moongo App.\n\nThe user shall be solely responsible for the authenticity, legality, harmlessness, accuracy, and validity of the information transmitted by using the "Moon go" account or this service. Any legal responsibility related to the information disseminated by the user shall be the user Take it on your own and have nothing to do with Moonblink Group. If any damage is caused to Moonblink Groupor a third party, the user shall be compensated according to law.\n\nThe services provided by Moonblink Groupmay include advertisements, and the user agrees to display advertisements provided by Moonblink Groupand third-party suppliers and partners during use. Except as clearly provided by laws and regulations, users shall be solely responsible for transactions based on the advertising information. Moonblink Group shall not be liable for any losses or damages suffered by users due to transactions based on the advertising information or the content provided by the aforementioned advertisers. responsibility.',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Account Managements',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nThe ownership of the "Moon go" account belongs to Moonblink Group. After the user completes the application and registration procedures, the user will obtain the right to use the "Moon go" account. The right to use only belongs to the initial application registrant. Gifts, borrowing, or renting are prohibited , Transfer or sale. Due to business needs, Moonblink Grouphas the right to reclaim the user\'s "Moon go" account.\n\n\The user can modify or delete the personal information, registration information and transmission content on the "Moon go" account, but it should be noted that deleting relevant information will also delete the text and pictures stored by the user in the system, and the user is responsible The risk.\n\nThe user is responsible for the safety of the registered account information and account password. The user is responsible for account theft or password theft due to improper storage of the user. The user shall bear legal responsibility for the behavior under the registered account and password. The user agrees not to use another user\'s account or password under any circumstances. When the user suspects that others are using his account or password, the user agrees to notify Moonblink Group immediately.\n\nThe user shall abide by the terms of this agreement, and use the service correctly and appropriately. If the user violates any of the terms in this agreement, Moonblink Group shall have the right to suspend or terminate the "fishing" of the user in accordance with the agreement after notifying the user. "Moon go" account provides services. At the same time, Moonblink Group reserves the right to withdraw the account and user name of the " Moon go" at any time.\n\nIf the user does not log in for one year after registering the "Moon go" account, Moonblink Group can withdraw the account after notifying the user to avoid waste of resources, and the user shall bear the adverse consequences caused by it.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Service Recharge',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nSome of the services of Moon go are provided by fee. If you use fee-based services, please abide by the relevant agreement.\n\nMoon go may modify and change the charging standards and methods of charging services according to actual needs, and Moon go may also start charging for some free services. Before the aforementioned amendments, changes, or charging starts, Moongo will notify or announce on the corresponding service page. If you do not agree to the above modification, change or paid content, you should stop using the service.\n\nAfter the user recharges, the recharge order number should be retained as a proof of verification for future problems (the user complains about the recharge service but does not have a valid recharge certificate to support it, the Moondog will not make compensation or compensation).\n\nWhen using the top-up method, the user must carefully confirm his account and carefully select the relevant operation options. If the user\'s account is incorrectly entered, the operation is improper, or the recharge billing method is not understood by the user, the wrong account number or the wrong recharge type is damaged due to factors such as the user\'s own account. Moongo will not make compensation or compensation.\n\nIf the user recharges in an illegal way, or uses a recharge method other than that specified by Moongo, Moongo does not guarantee the smooth or correct completion of the recharge. If the user\'s rights are damaged as a result, Moongo will not make compensation or compensation, and Moongo reserves the right to terminate the user\'s account qualification and use various recharge services at any time.\n\nThe user shall not conduct any illegal or criminal activities through the Moongo, otherwise the Moongo has the right to terminate the service. If the circumstances are serious, it will be transferred to the judicial authority according to law.\n\nAfter the recharge is successful, the virtual currency in the account added by the recharge can be used freely by the user, but Moongo will not provide refund or reverse exchange services.\n\nMoon go can change the service or update the terms of this agreement at any time according to business needs, but it should promptly prompt the revised content on the relevant page. Once the revised service agreement is published on the page, it will replace the original service agreement. Users can visit the latest user agreement of Moon go anytime.\n\nIf the network recharge service needs to be suspended due to the needs of system maintenance or upgrade, Moongo will make advance notice as far as possible.\n\nIn the event of any of the following situations, Moon go has the right to suspend or terminate the provision of network services under this agreement to users at any time without notifying users:\n - The personal information provided by the user is not true.\n - The user violates the usage rules stipulated in this agreement.\n\nDisclaimer and damages:\n - In the following circumstances, the Moon go is exempt from legal liability:\n - User disputes arising from the use of third-party payment channels to recharge\n - User property loss caused by the user telling others the password.\n - User property loss caused by the user\'s personal intention or gross negligence, or a third party outside of this agreement.\n - Various situations and disputes caused by force majeure and unforeseen situations; force majeure and unforeseen situations include: hacker attacks, technical adjustments of the telecommunications sector leading to major impacts, temporary closures caused by government control, and virus attacks.\n - The user agrees to protect and maintain the interests of Moongo and other users. If the user violates relevant laws, regulations or the terms of this agreement and causes losses to Moongo or other third parties, the user agrees to bear the responsibility. Liability for damage caused.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Data storage',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nMoonblink Group is not responsible for the user\'s failure to delete or store related data in this service.\n\nMoonblink Group can determine the maximum storage period of the user\'s data in this service according to the actual situation, and allocate the maximum storage space for the data on the server. Users can back up the relevant data in this service according to their own needs.We delete the user\’s top-day chat information every two weeks, and the user can save the chat history by himself\n\nIf the user stops using the service or the service is terminated, Moonblink Group can permanently delete the user\'s data from the server. After the service is stopped or terminated, Moonblink Group has no obligation to return any data to the user.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Risk Taking',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nThe user understands and agrees that "Moongo" only provides a platform for users to share, transmit and obtain information. Users must be responsible for all actions under theirregistered account, including any content transmitted by the user and any resulting as a result of. Users should make their own judgments on the content of "Moongo" and this service, and bear all risks arising from the use of the content, including risks arising from the reliance on the correctness, completeness or practicality of the content. Moonblink Group cannot and will not be liable for any loss or damage caused by user actions.\n\nIf the user finds that anyone has violated this agreement or used this service in other improper ways, please report or complain to Moonblink Group immediately, and Moonblink Group will handle it in accordance with the agreement.\n\nThe user understands and agrees that due to business development needs, Moonblink Group reserves the right to unilaterally change, suspend, terminate or cancel all or part of the service content, and the user shall bear this risk.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Intellectual Property Statement',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nExcept for the intellectual property rights related to advertisements in this service, which are enjoyed by the corresponding advertisers, the intellectual property rights of the content (including but not limited to web pages, text, pictures, audio, video, graphics, etc.) provided by Moonblink Group in this service are Owned by Moonblink Group, except that users have legally obtained intellectual property rights for their published content before using this service.\n\nUnless otherwise specifically stated, the copyright, patent rights and other intellectual property rights of the software on which Moonblink Group provides this service belong to Moonblink Group.\n\nMoonblink Group’s graphics, text or their composition, and other Moonblink Group logos and product and service names (hereinafter collectively referred to as the "Moonblink Group Logo") involved in this service, their copyright or trademark rights belong to Moonblink Group all. Without the written consent of Moonblink Group, the user shall not display or use the Moonblink Group logo in any way or do other processing, nor shall it indicate to others that the user has the right to display, use, or other rights to process the Moonblink Group logo.\n\nThe above and any other intellectual property rights owned by Moonblink Group or related advertisers in accordance with the law are protected by law. Without the written permission of Moonblink Group or related advertisers, users may not use or create related derivative works in any form.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Legal Liability',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nIf Moonblink Group discovers or receives reports from others or complaints that users have violated this agreement, Moonblink Group has the right to review and delete relevant content, including but not limited to user information and chat records, at any time withoutnotice. The severity of the circumstances imposes penalties including, but not limited to, warnings, account bans, device bans, and function bans on the offending account, and the user is notified of the results.\n\nUsers who are banned due to violation of the user agreement will be self-unblocked after the ban period expires. Among them, users who have been banned by the function will automatically restore the banned function after the ban period expires. The banned user can submit an appeal to the relevant page of the "https://moonblinkuniverse.com" website, and Moonblink Group will review the appeal and make a reasonable judgment on its own to decide whether to change the punishment measures.\n\nThe user understands and agrees that Moonblink Group has the right to penalize violations of relevant laws and regulations or the provisions of this agreement based on reasonable judgment, take appropriate legal actions against any user who violates laws and regulations, and save relevant information in accordance with laws and regulations. For departmental reports, etc., the user shall bear all legal responsibilities arising therefrom.\n\nThe user understands and agrees that the user shall compensate Moonblink Group and its cooperative companies and affiliated companies for any claims, demands or losses claimed by any third party caused or caused by the user\'s violation of this agreement, including reasonable attorney fees, and Keep it from harm.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Force majeure and other exemptions',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nThe user understands and confirms that in the process of using the service, risk factors such as force majeure may be encountered, which may cause the service to be interrupted. Force majeure refers to an objective event that cannot be foreseen, cannot be overcome, and cannot be avoided, and has a significant impact on one or both parties, including but not limited to natural disasters such as floods, earthquakes, epidemics and storms, and social events such as wars, turmoil, government actions, etc. . When the above situation occurs, Moonblink Group will try to cooperate with relevant units for the first time and provide timely repair feedback. However, Moonblink Group and its partners will be exempted from liability within the scope permitted by law for the losses caused to users or third parties.\n\nLike most Internet services, this service is affected by differences in factors including but not limited to user reasons, network service quality, social environment, etc., and may be harassed by various security issues, such as the use of user data by others to cause real life Harassment in the Internet; other software downloaded and installed by users or other websites visited contain viruses such as "Trojan horses", which threaten the security of users\' computer information and data, and then affect the normal use of this service. Users should strengthen the awareness of information security and user data protection, and should pay attention to strengthening password protection to avoid loss and harassment.\n\nThe user understands and confirms that the service is interrupted or cannot meet user requirements due to force majeure, computer viruses or hacker attacks, system instability, user location, user shutdown, and any other technology, Internet, communication line reasons, etc. Moonblink Group does not bear any responsibility for any loss of users or third parties caused by this.\n\nThe user understands and confirms that there is misleading, deceptive, threatening, defamatory, offensive or illegal information from any other person during the use of this service, or anonymity that violates the rights of others Moonblink Group does not assume any responsibility for any loss to users or third parties caused by the information or the fake information and the behaviors accompanying such information.\n\nThe user understands and confirms that Moonblink Group needs to overhaul or maintain the "moongo" platform or related equipment regularly or irregularly. If such a situation causes service interruption within a reasonable time, Moonblink Group does not need Take any responsibility for this, but Moonblink Group should make a notice in advance.\n\nMoonblink Group obtains the right to deal with illegal content or breach of contract in accordance with laws and regulations, and this agreement. This right does not constitute Moonblink Group’s obligations or commitments. Moonblink Group cannot guarantee timely detection of violations of laws or regulations or breaches of contract and deal with them accordingly .\n\nThe user understands and confirms that Moonblink Group does not assume any responsibility for the quality defects of the following products or services provided by Moonblink Group to users and any losses caused by them:\n - Moonblink Group provides free services to users.\n - Any products or services presented by Moonblink Group to users.\n\nUnder any circumstances, Moonblink Group will not cause any indirect, consequential, punitive, incidental, special or penal damages, including the loss of profits suffered by the user due to the use of the "moon go" for this service. Take responsibility (even if Moonblink Group has been informed of the possibility of such losses). Although this agreement may contain contradictory provisions, Moonblink Group’s full responsibility to users, regardless of the reason or behavior, will never exceed the fees paid by the user to Moonblink Group for using the services provided by Moonblink Group (If any).\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Service Change, Interruption and Termination',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nIn view of the particularity of network services, users agree that Moonblink Group has the right to change, interrupt or terminate part or all of the services (including fee-based services) at any time. Moonblink Group changes, interrupts or terminates the service, Moonblink Group shallnotify the user before the change, interruption or termination, and shall provide the affected users with equivalent alternative services; if the user is unwilling to accept alternative services , If the user has paid Moonblink Group related service fees, Moonblink Group shall deal with it in accordance with relevant legal provisions.\n\nIn the event of any of the following situations, Moonblink Group has the right to change, suspend or terminate the free services or charged services provided to users without any responsibility for the user or any third party:\n - According to the law, users should submit real information, and the personal information provided by the user is not true or inconsistent with the information at the time of registration and fails to provide reasonable proof.\n - The user violates relevant laws and regulations or the provisions of this agreement.\n - In accordance with legal provisions or requirements of competent authorities.\n - For safety reasons or other necessary circumstances.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                        Text('Other',
                            style: subtitleTextStyle,
                            textAlign: TextAlign.justify),
                        Text(
                            '\nMoonblink Group solemnly reminds users to pay attention to the clauses in this agreement that exempt Moonblink Group from liability and limit user rights. Users are requested to read carefully and consider risks independently. Minors should read this agreement accompanied by a legal guardian.\n\nThe validity, interpretation and dispute resolution of this agreement shall apply to the laws of the People\'s Republic of China. If any dispute or controversy occurs between the user and Moonblink Group, it should be settled through friendly negotiation. If the negotiation fails, the user agrees to submit the dispute or dispute to the people\'s court with jurisdiction in Moonblink Group\'s residence.\n\nAny clause of this agreement is invalid or unenforceable for any reason, the remaining clauses are still valid and binding on both parties.\n',
                            style: contentTextStyle,
                            textAlign: TextAlign.justify),
                      ],
                    ),
                  ),
                ),
              ),
              // if (newUser != false)
              // RaisedButton(
              //   onPressed: null,
              //   child: Text(hasUser.toString()),
              // ),
              if (hasUser == null && showAccept)
                Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                  width: double.infinity,
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Text(G.of(context).accept),
                    onPressed: () {
                      if (Platform.isAndroid) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, RouteName.login, (route) => false);
                      } else if (Platform.isIOS) {
                        Navigator.pushNamedAndRemoveUntil(context,
                            RouteName.licenseAgreement, (route) => false);
                      } else {
                        showToast('This platform is not supported');
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
