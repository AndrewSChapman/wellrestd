import { ApiClient } from "../apiClient";
import { ErrorHelper } from "../helpers/errorHelper";
import { StorageHelper } from "../helpers/storageHelper";
import { LoginResponse } from "./valueObjects/loginResponse";
import { OverlayLoader } from "../ui/overlayLoader";

enum MessageType { ALERT, ERROR, INFO }

export class LoginManager
{
    private _apiClient: ApiClient;
    private _errorHelper: ErrorHelper;
    private _storageHelper: StorageHelper;
    private _overlayLoader: OverlayLoader;

    private _$form: JQuery<HTMLElement>;
    private _$username: JQuery<HTMLElement>;
    private _$password: JQuery<HTMLElement>;
    private _$messages: JQuery<HTMLElement>;

    constructor(
        apiClient: ApiClient,
        errorHelper: ErrorHelper,
        storageHelper: StorageHelper
    ) {
        this._apiClient = apiClient;
        this._errorHelper = errorHelper;
        this._storageHelper = storageHelper;

        this._overlayLoader = new OverlayLoader('#frmLogin');

        this._$messages = $('div.messages');
        this._$form = $('#frmLogin');
        this._$username = this._$form.find('#username');
        this._$password = this._$form.find('#password');

        this.attachListeners();
    }

    private attachListeners(): void
    {
        this.onFormSubmit();
    }

    private onFormSubmit(): void
    {
        this._$form.on('submit', async (evt) => {
            evt.preventDefault();

            this.hideMessage();
            this._overlayLoader.render();

            try {
                const prefix = await this._storageHelper.getPrefix(this._apiClient);
    
                const loginRequest = {
                    'login': {
                        'prefix': prefix,
                        'username': this._$username.val(),
                        'password': this._$password.val(),
                    }
                }

                this._apiClient.post('login', loginRequest).then((response) => {
                    this._overlayLoader.remove();
                    const loginResponse: LoginResponse = LoginResponse.fromResponse(response);
                    this._storageHelper.setCookie('tokenCode', loginResponse.tokenCode);
                    this._storageHelper.setValue('usrId', loginResponse.usrId);
                    this._storageHelper.setValue('usrType', loginResponse.usrType);
                    window.location.href = '/';
                }, (error: any) => {
                    this._overlayLoader.remove();
                    this._errorHelper.resolveError(error);
                    const message: string = this._errorHelper.getMessage();
    
                    if (message != "") {
                        this.showError(message);
                    } else {
                        this.showError('Sorry, your login failed.  Please check your username and password and try again.');
                    }
                });
            } catch (error) {
                this._overlayLoader.remove();
                this.showError(error);
            }
        })
    }

    private showError(message: string): void
    {
        this.showMessage(message, MessageType.ERROR);
    }

    private showAlert(message: string): void
    {
        this.showMessage(message, MessageType.ALERT);
    }
    
    private showInfo(message: string): void
    {
        this.showMessage(message, MessageType.INFO);
    }    

    private showMessage(message: string, messageType: MessageType = MessageType.INFO): void
    {
        this._$messages.html(message);

        this._$messages.removeClass('alert');
        this._$messages.removeClass('info');
        this._$messages.removeClass('error');

        if (messageType == MessageType.ALERT) {
            this._$messages.addClass('alert');
        } else if(messageType == MessageType.INFO) {
            this._$messages.addClass('info');
        } else {
            this._$messages.addClass('error');
        }

        this._$messages.show();
    }

    private hideMessage()
    {
        this._$messages.hide();
    }
}