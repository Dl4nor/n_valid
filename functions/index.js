/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Importações
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

// Inicialização
admin.initializeApp();
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

// Função para envio de notificações e e-mails diários
exports.sendDailyNotificationAndMail = functions
    .pubsub
    .schedule("every day 05:00")
    .onRun(async (context) => {
      try {
        const usersSnapshot = await admin.firestore().collection("Users").get();

        const userNotifications = [];
        const userEmails = [];

        for (const userDoc of usersSnapshot.docs) {
          const userData = userDoc.data();
          const user = {
            CNPJ: userData.CNPJ,
            mail: userData.mail,
            name: userData.name,
            store: userData.store,
            userName: userData.userName,
            deviceToken: userData.deviceToken,
          };

          if (!user.CNPJ || !user.mail || !user.deviceToken) {
            console.warn(`Erro, user: ${userDoc.id}`);
            continue;
          }

          const storesSnapshot = await admin.firestore().collection("Stores")
              .where("CNPJ", "in", user.CNPJ)
              .get();

          for (const storeDoc of storesSnapshot.docs) {
            const storageSnapshot = await admin
                .firestore()
                .collection("Storage")
                .where("CNPJ", "==", storeDoc.data().CNPJ)
                .get();

            const newCautionProducts = [];
            let cautionProducts = 0;

            for (const productDoc of storageSnapshot.docs) {
              const productData = productDoc.data();

              const product = {
                dateExpiration: productData.dateExpiration.toDate(),
                dateEntry: productData.dateEntry.toDate(),
                name: productData.name,
              };

              const now = new Date();

              // Lógica de verificação de rebaixa
              const totalTime = product.dateExpiration - product.dateEntry;
              const threshold = totalTime / 4;
              const remainingTime = product.dateExpiration - now;

              if (remainingTime === threshold - 1) {
                newCautionProducts.push({
                  name: product.name,
                  dateExpiration: product.dateExpiration.toLocaleDateString(),
                });
              }
              if (remainingTime < threshold) {
                cautionProducts++;
              }
            }

            if (newCautionProducts.length > 0) {
              // Notificação para o dispositivo
              const notificationMessage = {
                notification: {
                  title: "Produtos entraram em Rebaixa!",
                  body: `${cautionProducts} Rebaixas em ${storeDoc.name}`,
                },
                data: {
                  products: JSON.stringify(newCautionProducts),
                },
                token: user.deviceToken,
              };
              userNotifications.push(admin
                  .messaging()
                  .send(notificationMessage),
              );

              // Conteúdo do e-mail
              const emailContent = `
                <h1>Relatório de produtos próximos ao vencimento</h1>
                <ul>
                  ${newCautionProducts.map((product) => `
                    <li>
                      <strong>Nome:</strong> ${product.name}<br>
                      <strong>Validade:</strong> ${product.dateExpiration}<br>
                    </li>
                  `).join("")}
                </ul>
              `;

              const emailMessage = {
                to: user.mail,
                from: "tccigov@gmail.com",
                subject: `${cautionProducts} Reabixas em ${storeDoc.name}`,
                html: emailContent,
              };

              userEmails.push(sgMail.send(emailMessage));
            }
          }
        }

        // Enviar notificações e e-mails em paralelo
        await Promise.all([...userNotifications, ...userEmails]);
        console.log("Notificações e e-mails enviados com sucesso!");
      } catch (error) {
        console.error("Erro ao enviar notificações ou e-mails: ", error);
      }
      return null;
    });
